#!/bin/bash

# Specify the heading or section to filter out
EXCLUSIONS=$3

# Input and output file paths
INPUT_FILE=$1
OUTPUT_FILE=$2

# Function to check if a given heading or section is in the exclusion list
isExcluded() {
    local value="$1"
    local exclusions="$2"
    for exclusion in $(echo "$exclusions" | tr ',' ' '); do
        if [ "$value" == "$exclusion" ]; then
            echo "0"
            return 0  # No match found, return failure
        fi
    done
    echo "1"
    return 1  # No match found, return failure
}

# Check if the filtered heading contains a section
section_excluded=false
heading_excluded=false

# Read the input file line by line
while IFS= read -r line; do
    # Check if the line starts with ## to determine the section
    if [[ "$line" =~ ^"## /" ]]; then
        heading_excluded=false
        # Extract the value after "## /"
        section_value="${line##*## /}"
        if [[ $(isExcluded "$section_value" "$EXCLUSIONS") -eq 0 ]]; then
          section_excluded=true
        else
          section_excluded=false
        fi
    fi

    if [[ "$line" =~ ^"### [" ]]; then
        # Extract the value after "## /"
        heading_value=$(echo "$line" | awk -F"[][]" '{print $2}')
        if [[ $(isExcluded "$section_value/$heading_value" "$EXCLUSIONS") -eq 0 ]]; then
          heading_excluded=true
        else
          heading_excluded=false
        fi
        echo $heading_excluded
    fi

    # Output the line if not skipping
    if [ "$section_excluded" = false ] && [ "$heading_excluded" = false ]; then
        echo "$line" >> "$OUTPUT_FILE"
    fi
done < "$INPUT_FILE"