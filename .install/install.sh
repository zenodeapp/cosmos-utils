#!/bin/bash

CURRENT=$(cd "$(dirname "$0")"/ && pwd)
VERSION=main
REPO=https://raw.githubusercontent.com/zenodeapp/cosmos-utils/$VERSION
# Download the file silently
wget -q $REPO/.version/.versionmap -O versionmap.txt

bla=""


# Check if download was successful
if [ $? -eq 0 ]; then
    echo "File downloaded successfully."

    # Read the file line by line
    while IFS= read -r line; do
  # Extract information from the line
  file_path=$(echo "$line" | awk '{print $1}')
  file_version=$(echo "$line" | awk '{print $2}')

  # Prompt the user
  if [ -z $bla ]; then
      bla=$file_path
  else
      bla=$bla,$file_path
  fi
    done < versionmap.txt

    # Optionally, you can remove the downloaded file after processing
    rm versionmap.txt
else
    echo "Failed to download the file."
fi

  
# Function to check if a given heading or section is in the exclusion list

for exclusion in $(echo "$bla" | tr ',' ' '); do
    echo $exclusion
    read -p "Do you want to update $exclusion? (Y/n) " response
    response=$(echo "$response" | tr 'A-Z' 'a-z')  # Convert to lowercase

if [ "$response" != "n" ]; then
    DIR=$(dirname "$exclusion")
    mkdir -p "$CURRENT/test/$DIR"
    wget -q "$REPO/$exclusion" -O "$CURRENT/test/$exclusion"
fi
done