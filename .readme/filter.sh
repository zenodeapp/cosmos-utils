#!/bin/bash

# Arguments
INPUT=$1
OUTPUT=$2
EXCLUSIONS=$3

# Variables
SECTION_EXCLUDED=false
SUB_SECTION_EXCLUDED=false

# Helper function: check if a given section or sub-section is excluded
isExcluded() {
    local VALUE="$1"
    for EXCLUSION in $(echo "$EXCLUSIONS" | tr ',' ' '); do
        if [ "$VALUE" == "$EXCLUSION" ]; then
            echo "1"
            return
        fi
    done
    echo "0"
}

# Read the input file line by line
while IFS= read -r LINE; do
    # Check if the line starts with ## to determine the section
    if [[ "$LINE" =~ ^"## /" ]]; then
        # Reset SUB_SECTION_EXCLUDED
        SUB_SECTION_EXCLUDED=false

        # Extract the value after "## /"
        SECTION_NAME="${LINE##*## /}"

        if [[ $(isExcluded "$SECTION_NAME") -eq 1 ]]; then
          SECTION_EXCLUDED=true
        else
          SECTION_EXCLUDED=false
        fi
    fi

    # Check if the line starts with ### to determine the sub-section
    if [[ "$LINE" =~ ^"### [" ]]; then
        # Extract the value after "## /"
        SUB_SECTION_NAME=$(echo "$LINE" | awk -F"[][]" '{print $2}')
        if [[ $(isExcluded "$SECTION_NAME/$SUB_SECTION_NAME") -eq 1 ]]; then
          SUB_SECTION_EXCLUDED=true
        else
          SUB_SECTION_EXCLUDED=false
        fi
    fi

    # Output the line if not skipping
    if [ "$SECTION_EXCLUDED" = false ] && [ "$SUB_SECTION_EXCLUDED" = false ]; then
        echo "$LINE" >> "$OUTPUT"
    fi
done < "$INPUT"