#!/bin/bash

# Specify the repository and file paths
REPO="zenodeapp/cosmos-utils"
FILE_PATHS=".version/.versionmap,README.md,backup/create.sh"
BRANCH="main"

# Make a request to the GitHub API without authentication for multiple file paths
API_URL="https://api.github.com/repos/$REPO/commits?path=$FILE_PATHS&sha=$BRANCH"

# Function to make API request with wget
makeApiRequest() {
    wget -qO- "$API_URL" | jq -r '.[0].sha'
}

# Make the API request without delay
LATEST_COMMIT=$(makeApiRequest)

# Print the latest commit SHA
echo $API_URL
echo "Latest commit for files in $REPO on branch $BRANCH: $LATEST_COMMIT"
