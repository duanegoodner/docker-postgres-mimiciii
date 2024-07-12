#!/bin/bash

# Base directory where files will be downloaded
base_dir="./mimic-code/a8308706d8f2bf3bbf42f5e7065094c648f64576"

# Ensure the urls.txt file exists
if [ ! -f mimic-urls.txt ]; then
  echo "mimic-urls.txt not found!"
  exit 1
fi

# Read the urls.txt file line by line
while IFS= read -r url; do
  # Check if the URL is for the LICENSE file
  if [[ "$url" == *"/blob/"* ]]; then
    # Modify the URL to use the raw file link
    url="${url/blob/raw}"
    # Set the path explicitly for the LICENSE file
    path="LICENSE"
  else
    # Extract the path from the URL after the commit hash
    path=$(echo "$url" | sed -E 's|https://raw.githubusercontent.com/[^/]+/[^/]+/[^/]+/||')
  fi

  # Create the full path by prepending the base directory
  full_path="${base_dir}/${path}"
  
  # Create the directory structure if it doesn't exist
  dir=$(dirname "$full_path")
  mkdir -p "$dir"
  
  # Download the file
  wget -q -O "$full_path" "$url"
done < mimic-urls.txt

echo "All files downloaded successfully."
