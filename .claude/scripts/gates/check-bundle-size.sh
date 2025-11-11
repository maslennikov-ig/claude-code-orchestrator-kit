#!/bin/bash
# Custom Quality Gate: Bundle Size Check
# Purpose: Ensure production bundle stays within size limits
# Blocking: false (warning only)

set -e

echo "🔍 Running bundle size check..."

# Configurable threshold (default 500KB)
BUNDLE_SIZE_LIMIT=${BUNDLE_SIZE_LIMIT:-512000}  # 500KB in bytes

# Find bundle file
BUNDLE_FILE="dist/bundle.js"
if [ ! -f "$BUNDLE_FILE" ]; then
  echo "⚠️  Warning: Bundle file not found at $BUNDLE_FILE"
  echo "   Run 'npm run build' first"
  exit 0  # Non-blocking, just warn
fi

# Get actual size
ACTUAL_SIZE=$(wc -c < "$BUNDLE_FILE")
ACTUAL_SIZE_KB=$((ACTUAL_SIZE / 1024))
LIMIT_KB=$((BUNDLE_SIZE_LIMIT / 1024))

echo "   Bundle: $BUNDLE_FILE"
echo "   Size: $ACTUAL_SIZE_KB KB"
echo "   Limit: $LIMIT_KB KB"

if [ "$ACTUAL_SIZE" -gt "$BUNDLE_SIZE_LIMIT" ]; then
  echo ""
  echo "⛔ Bundle size EXCEEDS limit!"
  echo "   Actual: $ACTUAL_SIZE_KB KB"
  echo "   Limit: $LIMIT_KB KB"
  echo "   Exceeded by: $((ACTUAL_SIZE_KB - LIMIT_KB)) KB"
  echo ""
  echo "Recommendations:"
  echo "   - Analyze bundle with: npm run analyze"
  echo "   - Remove unused dependencies"
  echo "   - Use code splitting"
  echo "   - Enable tree shaking"
  exit 1
fi

echo "✅ Bundle size OK: $ACTUAL_SIZE_KB KB (limit: $LIMIT_KB KB)"
echo ""
exit 0
