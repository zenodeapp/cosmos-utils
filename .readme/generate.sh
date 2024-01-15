#!/bin/bash

# Root of repository
ROOT=$(cd "$(dirname "$0")"/.. && pwd)

# Variables
MODULES="backup fetch info key service tools"
OUTPUT=$ROOT/README.md
INPUT=$ROOT/.readme/template.md

# Clear existing content in the destination README.md
echo "" > "$OUTPUT"

# Read the template content up to the placeholder
awk '/\[replace_with_module_readmes\]/ { exit } { print }' "$INPUT" >> "$OUTPUT"

# Loop through the modules and append their README content
for module in $modules; do
    README="$ROOT/${module}/README.md"

    if [ -f "$README" ]; then
        # Append module README content to the destination README.md
        echo "" >> "$OUTPUT"
        cat "$README" >> "$OUTPUT"
    fi
done

# Read the remaining content from the template file
awk '/\[replace_with_module_readmes\]/,0 { print }' "$INPUT" >> "$OUTPUT"

echo "New README.md generated."