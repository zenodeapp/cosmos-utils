#!/bin/bash

# Function to prompt the user for a yes/no answer
askYesNo() {
    local ANSWER
    ( exec </dev/tty && read -p "$1 (y/n): " ANSWER && case $ANSWER in
        [Yy]* ) return 0;;
        [Nn]* ) return 1;;
        * ) echo "Please answer yes or no." && return 1;;
    esac )
}

# Root of repository
ROOT=$(cd "$(dirname "$0")"/.. && pwd)

# Get version from config
CONFIG=$ROOT/.install/.config
VERSION=main

if [ -e "$CONFIG" ]; then
    line=$(grep "^version=" "$CONFIG")

    if [ -n "$line" ]; then
        VERSION=$(echo "$line" | cut -d '=' -f 2)
    else
        echo "A version has to be configured in the $CONFIG file, ex: 'version=main'."
        exit 1
    fi
else
  echo "A $CONFIG file is necessary to perform this script."
  exit 1
fi

echo ""
echo "The upgrader is set to use tag/commit/branch '$VERSION' (see: $CONFIG)."
read -p "Do you want to perform the upgrade using '$VERSION'? (y/N): " RESPONSE

RESPONSE=$(echo "$RESPONSE" | tr 'A-Z' 'a-z')  # Convert to lowercase

if [ "$RESPONSE" != "y" ]; then
    echo "Aborted. Make the necessary changes in the $CONFIG file before continuing."
    exit 1
fi

# Variables
REPO="https://raw.githubusercontent.com/zenodeapp/cosmos-utils/$VERSION"
REPO_VERSION_MAP="$REPO/.install/.versionmap"
LOCAL_VERSION_MAP="$ROOT/.install/.versionmap"
REMOTE_VERSION_MAP="$ROOT/.install/.versionmap.remote"
NEW_VERSION_MAP="$ROOT/.install/.versionmap.new"

# Download the remote version map
mkdir -p "$(dirname "$REMOTE_VERSION_MAP")"
wget -qO- "$REPO_VERSION_MAP" > $REMOTE_VERSION_MAP

# Compare local and remote version maps
while IFS= read -r remote_line; do
    remote_file=$(echo "$remote_line" | awk '{print $1}')
    remote_version=$(echo "$remote_line" | awk '{print $2}')

    # Check if the line exists in the local version map
    local_version=$(awk -v file="$remote_file" '$1==file {print $2}' "$LOCAL_VERSION_MAP")

    if [ -z "$local_version" ]; then
        # File is not present in local version map
        if askYesNo "File '$remote_file' is not present locally. Do you want to download it?"; then
            mkdir -p "$(dirname "$ROOT/$remote_file")"
            wget -q "$REPO/$remote_file" -O "$ROOT/$remote_file"
            echo "$remote_file $remote_version" >> "$NEW_VERSION_MAP"
        fi
    else
        # File is present in both local and remote version maps
        if [ "$local_version" != "$remote_version" ]; then
            # Versions differ
            if askYesNo "Version mismatch for '$remote_file'. Local version: $local_version, Remote version: $remote_version. Do you want to update?"; then
                mkdir -p "$(dirname "$ROOT/$remote_file")"
                wget -q "$REPO/$remote_file" -O "$ROOT/$remote_file"

                if [ "$remote_file" = ".install/updater.sh" ]; then
                    echo "$remote_file $remote_version" >> "$NEW_VERSION_MAP"
                    tail -n +2 "$LOCAL_VERSION_MAP" >> "$NEW_VERSION_MAP"
                    cat $NEW_VERSION_MAP > "$LOCAL_VERSION_MAP"
                    
                    # Clean up temporary files
                    rm "$REMOTE_VERSION_MAP"
                    rm "$NEW_VERSION_MAP"
                    
                    echo "The updater.sh script has been updated. Please restart the script for changes to take effect."
                    exit 0
                fi

                echo "$remote_file $remote_version" >> "$NEW_VERSION_MAP"
            else
                # Keep the local version in the new version map
                echo "$remote_file $local_version" >> "$NEW_VERSION_MAP"
            fi
        else
            # Versions are the same
            echo "$remote_file $remote_version" >> "$NEW_VERSION_MAP"
        fi
    fi
done < $REMOTE_VERSION_MAP

# Check for files in local version map not present in remote version map
while IFS= read -r local_line; do
    local_file=$(echo "$local_line" | awk '{print $1}')

    # Check if the file is not present in the remote version map
    if ! grep -q "$local_file" $REMOTE_VERSION_MAP; then
        # File is not present in remote version map
        if askYesNo "File '$local_file' is not present in the remote version map. Do you want to remove it?"; then
            rm "$ROOT/$local_file"
        else
            # Keep the local version in the new version map
            local_version=$(awk -v file="$local_file" '$1==file {print $2}' "$LOCAL_VERSION_MAP")
            echo "$local_file $local_version" >> "$NEW_VERSION_MAP"
        fi
    fi
done < "$LOCAL_VERSION_MAP"

# Recreate the new local version map
cat $NEW_VERSION_MAP > "$LOCAL_VERSION_MAP"

# Clean up temporary files
rm "$REMOTE_VERSION_MAP"
rm "$NEW_VERSION_MAP"