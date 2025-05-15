import json
import os

# Unzip output.zip
import zipfile
zip_path = 'data/alltheplaces/output.zip'
extract_path = os.path.splitext(zip_path)[0]
with zipfile.ZipFile(zip_path, 'r') as zip_ref:
    zip_ref.extractall(extract_path)
# Now delete output.zip
os.remove(zip_path)

# Path to the directory containing the .geojson files
base_path = 'data/alltheplaces'
folder_path = 'data/alltheplaces/output/output'

# Initialize an empty list to store the filtered features
filtered_features = []

# Iterate over the files in the directory
for filename in os.listdir(folder_path):
    if filename.endswith('.geojson'):
        print(filename)
        file_path = os.path.join(folder_path, filename)
        # Open and load the geojson file
        try:
            with open(file_path, 'r') as file:
                data = json.load(file)
        except:
            print(filename, "could not be loaded")
            continue
        # Check if the file contains features
        if 'features' in data:
            for feature in data['features']:
                # Extract the coordinates from the current feature
                if 'geometry' in feature and feature['geometry'] is not None:
                    # Add a source field indicating the source file to the feature
                    feature['properties']['source'] = filename
                    # Add the feature to the filtered features list
                    filtered_features.append(feature)

# Create a new geojson structure with the filtered features
filtered_geojson = {
    "type": "FeatureCollection",
    "features": filtered_features
}

# Define the output file name
output_path = os.path.join(base_path, 'alltheplaces.geojson')

# Save the filtered features to a new geojson file
with open(output_path, 'w') as outfile:
    json.dump(filtered_geojson, outfile)

print(f'Filtered GeoJSON saved to {output_path}')


# Count occurrence
# import json
# from collections import Counter

# # Initialize a Counter object to hold the field counts
# field_counts = Counter()

# # Iterate over each feature in the GeoJSON file
# for feature in filtered_geojson['features']:
#     # Get the properties dictionary of the current feature
#     properties = feature['properties']
#     # Update the counter with the properties' fields
#     field_counts.update(properties.keys())

# # Sort fields by count in descending order and get the top 30
# top_fields = field_counts.most_common(30)

# # Display the top 30 fields and their counts
# for field, count in top_fields:
#     print(f'{field}: {count}')


top_fields = ['@spider', 'addr:country', 'source', 'addr:city', 'amenity', 'ref', 'name', 'brand', 'brand:wikidata', 'nsi_id', 
              'addr:postcode', 'addr:state', 'operator', 'located_in', 'shop', 'operator:wikidata']

# Extract the data
data = []
for feature in filtered_geojson['features']:
    properties = feature['properties']
    # Extract the latitude and longitude from the geometry
    # Assuming the geometry type is 'Point'
    coordinates = feature['geometry']['coordinates']
    while isinstance(coordinates[0], list):
        coordinates = coordinates[0]
    longitude, latitude = coordinates[0], coordinates[1]
    # Extract the top fields and handle cases where the field might not be present
    row = {field: properties.get(field, None) for field in top_fields}
    # Add latitude and longitude to the row
    row['longitude'] = longitude
    row['latitude'] = latitude
    # Append the row to our data list
    data.append(row)

import pandas as pd
# Create a DataFrame from the data list
data = pd.DataFrame(data)
data['addr:country'].value_counts()[:40]

# Remove countries AU, US, GB, IT, RU, CH, DE
data = data[~data['addr:country'].isin(['AU', 'US', 'GB', 'IT', 'RU', 'CH', 'DE', 'FR', 'CA', 'AT', 'BE', 'NL', 'ES', 'SE', 'IT'])]

# Save the DataFrame to a CSV file
output_path = os.path.join(base_path, 'alltheplaces.csv')
data.to_csv(output_path, index=False)

# Optionally, display the DataFrame
print(data.head())

# Finally, delete the folder
import shutil

def onerror(func, path, exc_info):
    if os.path.exists(path):
        os.chmod(path, 0o777)  # change permissions to allow deletion
        func(path)

shutil.rmtree(extract_path, onerror=onerror)

os.remove(os.path.join(base_path, 'alltheplaces.geojson'))

## Generate Folium Hap (HTML-based, too big!)
# import folium
# # Define the initial location for your map (latitude and longitude)
# # For example, using the center of the coordinates you provided
# initial_location = [(minlat + maxlat) / 2, (minlon + maxlon) / 2]
# # Create a folium map object
# m = folium.Map(location=initial_location, zoom_start=5)
# # Add the GeoJSON overlay to the map
# folium.GeoJson(
#     filtered_geojson,
#     name='geojson'
# ).add_to(m)

# # Add Layer control to toggle on/off
# folium.LayerControl().add_to(m)
# # Save the map to an HTML file
# m.save(folder_path + '_africa_map.html')
# # Display the map in a Jupyter notebook (if you are using one)
# m
