import os
import requests
from bs4 import BeautifulSoup

# URL of the website where the file is located
url = 'https://data.alltheplaces.xyz/runs/latest/info_embed.html'  # Replace with the actual URL

# Specify the folder where you want to save the downloaded file
download_folder = 'data/alltheplaces'  # Replace with the actual path

# Perform a GET request to fetch the HTML content
response = requests.get(url)
response.raise_for_status()  # Raises an HTTPError if the HTTP request returned an unsuccessful status code

# Parse the HTML content
soup = BeautifulSoup(response.text, 'html.parser')

# Search for all <a> tags to find the download link
for link in soup.find_all('a'):
    # Check if the link's text or href contains the file name 'output.zip'
    if 'output.zip' in link.get('href', ''):
        # Construct the full URL to the file
        download_url = link['href']
        # Perform a GET request to download the file
        file_response = requests.get(download_url)
        file_response.raise_for_status()
        # Define the download path
        download_path = os.path.join(download_folder, 'output.zip')
        # Write the file to the specified folder
        with open(download_path, 'wb') as file:
            file.write(file_response.content)
        print(f'File downloaded to {download_path}')
        break
else:
    print('No download link found for output.zip on the website.')
