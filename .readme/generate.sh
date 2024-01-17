#!/bin/bash

# Existing modules
MODULES="backup fetch info key service tools"

# Root of repository
ROOT=$(cd "$(dirname "$0")"/.. && pwd)

# Flags (default values)
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
INPUT=$ROOT/.readme/$TEMPLATE.md
TEMP=$ROOT/README.md.tmp
OUTPUT=$ROOT/README.md

# Check if the specified template file exists
if [ ! -f "$INPUT" ]; then
    echo "Error: Template file '$INPUT' not found."
    exit 1
fi

# Clear existing content in the destination README.md and README.md.tmp
echo -n "" > "$OUTPUT"
echo -n "" > "$TEMP"

# Header of README.md
awk '/\[replace_with_module_readmes\]/ { exit } { print }' "$INPUT" >> "$OUTPUT"

# Body of README.md (outputted to a temporary file)
for MODULE in $MODULES; do
    MODULE_README="$ROOT/${MODULE}/README.md"
    if [ -f "$MODULE_README" ]; then
        # Looks like a difficult regex expression, but this makes sure ../ gets replaced with ./
        awk '{gsub(/\]\(\.\.\//, "](./"); print}' "$MODULE_README" >> "$TEMP"
        # Add a trailing newline
        echo "" >> "$TEMP"
    fi
done

# Filter body if exclusion list added and append it to the README.md
if [ -z $EXCLUDE ]; then
    cat "$TEMP" >> "$OUTPUT"
else
    bash $ROOT/.readme/filter.sh "$TEMP" "$OUTPUT" "$EXCLUDE"
fi

# Cleanup
rm $TEMP

# Footer of README.md
awk '/\[replace_with_module_readmes\]/ { f=1; next } f { print }' "$INPUT" >> "$OUTPUT"

echo "README.md has been regenerated."

