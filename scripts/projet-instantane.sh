#!/bin/bash
OUTPUT=/tmp/projet-instantane.txt

echo "=== STRUCTURE ===" > "$OUTPUT"
find . -type f -not -path './.git/*' | sort >> "$OUTPUT"

echo "" >> "$OUTPUT"
echo "=== CONTENU ===" >> "$OUTPUT"

for f in $(find . -type f \
    \( -name "*.sh" -o -name "*.py" -o -name "*.conf" \
       -o -name "*.md" -o -name "*.html" -o -name "*.txt" \) \
    -not -path './.git/*' -not -name ".*.swp" | sort); do
    echo "--- $f ---" >> "$OUTPUT"
    cat "$f" >> "$OUTPUT"
    echo "" >> "$OUTPUT"
done

cat "$OUTPUT"
