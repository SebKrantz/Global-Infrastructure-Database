import csv
import json
import os
import shutil
import sys
import zipfile

# ---------------------------------------------------------------------------
# Unzip output.zip
# ---------------------------------------------------------------------------
zip_path = 'data/alltheplaces/output.zip'
extract_path = os.path.splitext(zip_path)[0]
with zipfile.ZipFile(zip_path, 'r') as zip_ref:
    zip_ref.extractall(extract_path)

base_path = 'data/alltheplaces'
folder_path = 'data/alltheplaces/output/output'
os.makedirs(base_path, exist_ok=True)

# ---------------------------------------------------------------------------
# Fields to extract (matches the columns expected by combine_points.R after
# janitor::clean_names(): '@spider' -> 'spider', 'addr:city' -> 'addr_city', etc.)
# ---------------------------------------------------------------------------
top_fields = [
    '@spider', 'addr:country', 'source', 'addr:city', 'amenity', 'ref', 'name',
    'brand', 'brand:wikidata', 'nsi_id', 'addr:postcode', 'addr:state',
    'operator', 'located_in', 'shop', 'operator:wikidata',
]
csv_columns = top_fields + ['longitude', 'latitude']

# ---------------------------------------------------------------------------
# Stream: one GeoJSON file at a time -> one CSV row at a time.
# Peak memory = size of the largest single GeoJSON file, not the full corpus.
# ---------------------------------------------------------------------------
output_path = os.path.join(base_path, 'alltheplaces.csv')
load_errors = 0

with open(output_path, 'w', newline='', encoding='utf-8') as csvfile:
    writer = csv.DictWriter(csvfile, fieldnames=csv_columns, extrasaction='ignore')
    writer.writeheader()

    for filename in sorted(os.listdir(folder_path)):
        if not filename.endswith('.geojson'):
            continue
        file_path = os.path.join(folder_path, filename)
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                data = json.load(f)
        except Exception:
            load_errors += 1
            continue

        if 'features' not in data:
            continue

        for feature in data['features']:
            if 'geometry' not in feature or feature['geometry'] is None:
                continue
            coords = feature['geometry']['coordinates']
            # Unwrap nested coordinate lists (MultiPoint / GeometryCollection edge cases)
            while isinstance(coords[0], list):
                coords = coords[0]
            props = feature['properties']
            row = {field: props.get(field, None) for field in top_fields}
            row['source'] = filename   # overwrite with clean filename
            row['longitude'] = coords[0]
            row['latitude'] = coords[1]
            writer.writerow(row)

if load_errors:
    print(f'Warning: {load_errors} geojson file(s) could not be loaded', file=sys.stderr)

# ---------------------------------------------------------------------------
# Clean up extracted directory
# ---------------------------------------------------------------------------
shutil.rmtree(extract_path, ignore_errors=True)
