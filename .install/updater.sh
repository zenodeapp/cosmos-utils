#!/bin/bash

# Function to prompt the user for a yes/no answer (defaults to yes)
askYesNo() {
    local ANSWER
    ( exec </dev/tty && read -p "$1 (Y/n): " ANSWER && case $ANSWER in
        [Yy]* ) return 0;;
        [Nn]* ) return 1;;
        * ) return 0;;
    esac )
}

# Root of repository
ROOT=$(cd "$(dirname "$0")"/.. && pwd)

# Parse command-line arguments
while [ $# -gt 0 ]; do
    case "$1" in
        --version)
            shift
            if [ $# -gt 0 ]; then
                VERSION="$1"
            else
                echo "Error: --version option requires a value."
                exit 1
            fi
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
    shift
done

# Get version from config
CONFIG=$ROOT/.install/.config

# Default version if not provided
if [ -z "$VERSION" ]; then
    if [ -e "$CONFIG" ]; then
        line=$(grep "^version=" "$CONFIG")

        if [ -n "$line" ]; then
            VERSION=$(echo "$line" | cut -d '=' -f 2)
        fi
    fi
else
    # Add version to .config file
    echo "version=$VERSION" > "$CONFIG"
fi

if [ -z "$VERSION" ]; then
    VERSION=main
fi

echo "COSMOS UTILS UPGRADER"
echo ""
echo "The upgrader is set to use tag/commit/branch '$VERSION' (add the flag \e[3m--version [tag|commit|branch]\e[0m to change this)."
echo ""
echo "CAUTION: running this will regenerate the README.md, if you made any custom changes, make sure to create a backup before continuing."
echo ""
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
EXCLUDE=""
CHANGE_MADE=false
UPGRADE_FOUND=false

# Function to perform cleanup
cleanup() {
    rm -r "$REMOTE_VERSION_MAP" "$NEW_VERSION_MAP" "$ROOT/.readme" > /dev/null 2>&1
}

# Clean up temporary files
cleanup

# Download necessary files for readme alterations
mkdir -p "$ROOT/.readme"
wget --no-cache -qO- "$REPO/.readme/generate.sh" > $ROOT/.readme/generate.sh
wget --no-cache -qO- "$REPO/.readme/filter.sh" > $ROOT/.readme/filter.sh
wget --no-cache -qO- "$REPO/.readme/template-installed.md" > $ROOT/.readme/template-installed.md

# Function to download a file
downloadFile() {
    local remote_file="$1"
    local remote_version="$2"
    local remote_type="$3"
    local prompt="$4"

    if askYesNo "$prompt"; then
        mkdir -p "$(dirname "$ROOT/$remote_file")"
        wget --no-cache -q "$REPO/$remote_file" -O "$ROOT/$remote_file"
        echo "$remote_file $remote_version $remote_type" >> "$NEW_VERSION_MAP"

        case "$remote_type" in
            d)
                bash $ROOT/.readme/filter.sh "$ROOT/$remote_file" "$ROOT/$remote_file.tmp" "$EXCLUDE"
                cat "$ROOT/$remote_file.tmp" > "$ROOT/$remote_file"
                rm "$ROOT/$remote_file.tmp"
                ;;
        esac

        case "$remote_file" in
            .install/updater.sh)
                # Custom behavior for updater.sh
                tail -n +2 "$LOCAL_VERSION_MAP" >> "$NEW_VERSION_MAP"
                cat $NEW_VERSION_MAP > "$LOCAL_VERSION_MAP"

                # Clean up temporary files
                cleanup
                
                echo "The updater.sh script has been updated. Please restart the script for changes to take effect."
                exit 0
                ;;
        esac

        CHANGE_MADE=true
        return 0  # Indicates success
    else
        return 1  # Indicates "No" response
    fi
}

# Download the remote version map
mkdir -p "$(dirname "$REMOTE_VERSION_MAP")"
wget --no-cache -qO- "$REPO_VERSION_MAP" > $REMOTE_VERSION_MAP

# Compare local and remote version maps
while IFS= read -r remote_line; do
    remote_file=$(echo "$remote_line" | awk '{print $1}')
    remote_version=$(echo "$remote_line" | awk '{print $2}')
    remote_type=$(echo "$remote_line" | awk '{print $3}')

    # Check if the line exists in the local version map
    local_version=$(awk -v file="$remote_file" '$1==file {print $2}' "$LOCAL_VERSION_MAP")

    # File is not present in local version map
    if [ -z "$local_version" ]; then
        # Default prompt
        prompt="File '$remote_file' is not present locally. Do you want to download it?"

        # Utility prompt
        if [ "$remote_type" = "u" ]; then
            prompt="New utility '$remote_file' detected. Do you want to download it?"
        fi

        if ! downloadFile "$remote_file" "$remote_version" "$remote_type" "$prompt"; then
            EXCLUDE="$EXCLUDE,$remote_file"
        fi
    else
        if [ "$local_version" != "$remote_version" ]; then
            # Default prompt
            prompt="Version mismatch for '$remote_file'. Local version: $local_version, Remote version: $remote_version. Do you want to update?"

            UPGRADE_FOUND=true
           
            # Versions differ
            if ! downloadFile "$remote_file" "$remote_version" "$remote_type" "$prompt"; then
                echo "$remote_file $local_version $remote_type" >> "$NEW_VERSION_MAP"
            fi
        else
            echo "$remote_file $remote_version $remote_type" >> "$NEW_VERSION_MAP"
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

            # Check if the directory is empty and remove it
            DIR=$(dirname "$ROOT/$local_file")
            if [ -z "$(ls -A "$DIR")" ]; then
                rmdir "$DIR"  # Remove the directory if it's empty
            fi

            # Exclude from readme
            EXCLUDE="$EXCLUDE,$local_file"
            CHANGE_MADE=true
        else
            # Keep the local version in the new version map
            local_version=$(awk -v file="$local_file" '$1==file {print $2}' "$LOCAL_VERSION_MAP")
            local_type=$(awk -v file="$local_file" '$1==file {print $3}' "$LOCAL_VERSION_MAP")
            echo "$local_file $local_version $local_type" >> "$NEW_VERSION_MAP"
        fi
    fi
done < "$LOCAL_VERSION_MAP"

# Recreate the new local version map
cat $NEW_VERSION_MAP > "$LOCAL_VERSION_MAP"

if ! $CHANGE_MADE && ! $UPGRADE_FOUND; then
  echo "Already up to date."
elif $CHANGE_MADE; then
  echo "Changes made successfully."
fi

# Regenerate README if change detected
sh $ROOT/.readme/generate.sh --template "template-installed"

# Clean up temporary files
cleanup