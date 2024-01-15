#!/bin/bash

# Specify the heading or section to filter out
FILTERED_HEADING=$3

# Input and output file paths
INPUT_FILE=$1
OUTPUT_FILE=$2

# Flag to indicate whether to skip the undesired heading and its content
SKIP=false

# Flag to indicate whether the current line is within the target section
WITHIN_SECTION=false

# Section and heading to filter out
TARGET_SECTION=""
TARGET_HEADING=""

# Check if the filtered heading contains a section
if [[ "$FILTERED_HEADING" == *"/"* ]]; then
    TARGET_SECTION=$(echo "$FILTERED_HEADING" | cut -d '/' -f 1)
    TARGET_HEADING=$(echo "$FILTERED_HEADING" | cut -d '/' -f 2)
else
    TARGET_SECTION="$FILTERED_HEADING"
fi

# Read the input file line by line
while IFS= read -r line; do
    # Check if the line starts with ## to determine the section
    if [[ "$line" =~ ^"## "/ ]]; then
        if [[ "$line" == "## /$TARGET_SECTION"* ]]; then
            WITHIN_SECTION=true
            # Output the line if within the target section
            if [ -z $TARGET_HEADING ]; then
                SKIP=true
            fi
        else
            WITHIN_SECTION=false
            SKIP=false
        fi
    fi

    # Check if the line starts with the heading to filter out
    if [[ "$line" =~ ^"### [$TARGET_HEADING]"* && "$WITHIN_SECTION" == true ]]; then
        SKIP=true
    elif [[ "$line" =~ ^"### "* && "$SKIP" == true ]]; then
        SKIP=false
    fi

    # Output the line if not skipping
    if [ "$SKIP" != true ]; then
        echo "$line" >> "$OUTPUT_FILE"
    fi
done < "$INPUT_FILE"