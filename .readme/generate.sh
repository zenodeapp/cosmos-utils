#!/bin/bash

# Root of repository
ROOT=$(cd "$(dirname "$0")"/.. && pwd)

# Default template file
TEMPLATE="template"
EXCLUDE=""

# Parse command-line arguments
while [ $# -gt 0 ]; do
    case "$1" in
        --template)
            shift
            if [ $# -gt 0 ]; then
                TEMPLATE="$1"
            else
                echo "Error: --template option requires a value."
                exit 1
            fi
            ;;
        --exclude)
            shift
            if [ $# -gt 0 ]; then
                EXCLUDE="$1"
            else
                echo "Error: --exclude option requires a value."
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

# Variables
MODULES="backup fetch info key service tools"
OUTPUT=$ROOT/README.md
TEMP=$ROOT/README.md.tmp
INPUT=$ROOT/.readme/$TEMPLATE.md

# Check if the specified template file exists
if [ ! -f "$INPUT" ]; then
    echo "Error: Template file '$INPUT' not found."
    exit 1
fi

# Clear existing content in the destination README.md and README.md.tmp
echo "" > "$OUTPUT"

# Read the template content up to the placeholder
awk '/\[replace_with_module_readmes\]/ { exit } { print }' "$INPUT" >> "$OUTPUT"

# Loop through the modules and append their README content
for MODULE in $MODULES; do
    README="$ROOT/${MODULE}/README.md"
    if [ -f "$README" ]; then
        # Append module README content to the destination README.md
        echo "" >> "$TEMP"
        # cat "$README" >> "$OUTPUT"
        awk '{gsub(/\]\(\.\.\//, "](./"); print}' "$README" >> "$TEMP"
    fi
done

# Filter out undesired heading and append the filtered content to README.md
if [ -z $EXCLUDE ]; then
    cat "$TEMP" >> "$OUTPUT"
else
    bash $ROOT/.readme/filter.sh "$TEMP" "$OUTPUT" "$EXCLUDE"
fi

# Read the remaining content from the template file
awk '/\[replace_with_module_readmes\]/ { f=1; next } f { print }' "$INPUT" >> "$OUTPUT"

echo "New README.md generated."

# Remove tmp fle
rm $TEMP