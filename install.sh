#!/bin/bash

# Path to .versionmap file
VERSION_MAP=".versionmap"

# Read each line in the .versionmap file
while IFS= read -r line; do
  # Extract information from the line
  file_path=$(echo "$line" | awk '{print $1}')
  force_pull=$(echo "$line" | awk '{print $2}')

  # Prompt the user
  read -p "Do you want to pull $file_path? (y/n) " response

  if [ "$response" == "y" ] || [ "$response" == "Y" ]; then
    # Perform the pull
    if [ "$force_pull" == "f" ]; then
      git checkout -- "$file_path"
    else
      git pull origin master --no-commit --no-ff -- "$file_path"
    fi
    echo "Pulled $file_path"
  else
    echo "Skipped pulling $file_path"
  fi

done < "$VERSION_MAP"

echo "Pulling complete."