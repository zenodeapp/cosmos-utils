#!/bin/bash

ROOT=$(cd "$(dirname "$0")"/.. && pwd)
REPO="https://raw.githubusercontent.com/zenodeapp/cosmos-utils/main"
REPO_VERSION_MAP="$REPO/.install/.versionmap"
LOCAL_VERSION_MAP="$ROOT/.install/.versionmap"
REMOTE_VERSION_MAP="$ROOT/.install/.versionmap.remote"
NEW_VERSION_MAP="$ROOT/.install/.versionmap.new"

# Function to prompt the user for a yes/no answer
askYesNo() {
    local answer
    ( exec </dev/tty && read -p "$1 (y/n): " answer && case $answer in
        [Yy]* ) return 0;;
        [Nn]* ) return 1;;
        * ) echo "Please answer yes or no." && return 1;;
    esac )
}

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
