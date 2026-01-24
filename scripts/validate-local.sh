#!/bin/bash
#
# validate-local.sh - Validate image files locally before committing
#
# This script performs the same validation checks as the GitHub Actions workflow
# Run this before committing changes to catch issues early
#

set -euo pipefail

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Docker Image Files Validation"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

FAILED=0

# Check 1: Trailing whitespace
echo "1. Checking for trailing whitespace..."
if find images -type f -exec grep -l ' $' {} \; 2>/dev/null | grep -q .; then
  echo "   ❌ Found trailing whitespace in:"
  find images -type f -exec grep -l ' $' {} \;
  FAILED=1
else
  echo "   ✅ No trailing whitespace"
fi
echo ""

# Check 2: Final newline
echo "2. Checking for final newline..."
missing_newline=0
while IFS= read -r file; do
  if [ -n "$(tail -c 1 "$file")" ]; then
    echo "   ❌ Missing final newline: $file"
    missing_newline=1
    FAILED=1
  fi
done < <(find images -type f)

if [ $missing_newline -eq 0 ]; then
  echo "   ✅ All files have final newline"
fi
echo ""

# Check 3: Duplicate tags
echo "3. Checking for duplicate tags..."
has_duplicates=0
while IFS= read -r file; do
  duplicates=$(grep -v '^[[:space:]]*$' "$file" | sort | uniq -d)
  if [ -n "$duplicates" ]; then
    echo "   ❌ Duplicate tags in $file:"
    echo "$duplicates" | sed 's/^/      /'
    has_duplicates=1
    FAILED=1
  fi
done < <(find images -type f)

if [ $has_duplicates -eq 0 ]; then
  echo "   ✅ No duplicate tags"
fi
echo ""

# Check 4: Empty files
echo "4. Checking for empty files..."
has_empty=0
while IFS= read -r file; do
  if ! grep -q '[^[:space:]]' "$file"; then
    echo "   ❌ Empty or whitespace-only: $file"
    has_empty=1
    FAILED=1
  fi
done < <(find images -type f)

if [ $has_empty -eq 0 ]; then
  echo "   ✅ No empty files"
fi
echo ""

# Check 5: File naming
echo "5. Validating file naming conventions..."
has_invalid=0
while IFS= read -r file; do
  filename=$(basename "$file")
  if [[ "$filename" =~ [A-Z] ]]; then
    echo "   ❌ Uppercase in filename: $file"
    has_invalid=1
    FAILED=1
  fi
  if [[ "$filename" =~ [[:space:]] ]]; then
    echo "   ❌ Spaces in filename: $file"
    has_invalid=1
    FAILED=1
  fi
done < <(find images -type f)

if [ $has_invalid -eq 0 ]; then
  echo "   ✅ All filenames valid"
fi
echo ""

# Check 6: Matrix generation
echo "6. Testing matrix generation..."
if command -v jq &> /dev/null; then
  matrix=$(find images -type f -printf '%P\n' | jq -R '{"image": .}' | jq -cs '{"include": .}')
  count=$(echo "$matrix" | jq '.include | length')
  echo "   ✅ Matrix generated successfully ($count images)"
else
  echo "   ⚠️  jq not installed, skipping matrix test"
fi
echo ""

# Summary
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
if [ $FAILED -eq 0 ]; then
  echo "✅ All validation checks passed!"
  echo ""
  echo "Total images: $(find images -type f | wc -l)"
  echo ""
  echo "You can now commit and push your changes."
  exit 0
else
  echo "❌ Validation failed!"
  echo ""
  echo "Please fix the issues above before committing."
  exit 1
fi
