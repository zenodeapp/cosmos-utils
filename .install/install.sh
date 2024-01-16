#!/bin/bash

CURRENT=$(cd "$(dirname "$0")"/ && pwd)
VERSION=main
REPO_ID="zenodeapp/cosmos-utils"
REPO=https://raw.githubusercontent.com/$REPO_ID/$VERSION

# Download the file silently
wget -q "$REPO/.version/.versionmap" -O versionmap.txt

VERSIONMAP=""

# Check if download was successful
if [ $? -eq 0 ]; then
    echo "File downloaded successfully."

    # Read the file line by line
    while IFS= read -r line; do
  # Extract information from the line
  file_path=$(echo "$line" | awk '{print $1}')
  file_version=$(echo "$line" | awk '{print $2}')

  # Prompt the user
  if [ -z $VERSIONMAP ]; then
      VERSIONMAP=$file_path
  else
      VERSIONMAP=$VERSIONMAP,$file_path
  fi
    done < versionmap.txt

    # Optionally, you can remove the downloaded file after processing
    # rm versionmap.txt
else
    echo "Failed to download the .versionmap, please try again or update the installer."
    exit 1
fi

  
# Function to check if a given heading or section is in the exclusion list

for exclusion in $(echo "$VERSIONMAP" | tr ',' ' '); do
    echo $exclusion
    # read -p "Do you want to update $exclusion? (Y/n) " response
    # response=$(echo "$response" | tr 'A-Z' 'a-z')  # Convert to lowercase

    # Make a request to the GitHub API to get the latest commit information for the file
    # API_URL="https://api.github.com/repos/$REPO_ID/commits?path=$exclusion&sha=$VERSION"
    # LATEST_COMMIT=$(wget -qO- "$API_URL" | jq -r '.[0].sha')
    # echo "$API_URL"
    # echo "Latest commit for $exclusion in $REPO_ID on branch $VERSION: $LATEST_COMMIT"

# if [ "$response" != "n" ]; then
    DIR=$(dirname "$exclusion")
    mkdir -p "$CURRENT/.build/$DIR"
    wget -q "$REPO/$exclusion" -O "$CURRENT/.build/$exclusion"
# fi
done