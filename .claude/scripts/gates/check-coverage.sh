#!/bin/bash
# Custom Quality Gate: Code Coverage
# Purpose: Ensure test coverage meets minimum threshold
# Blocking: false (warning only)

set -e

echo "🔍 Running code coverage check..."

# Configurable threshold (default 80%)
COVERAGE_THRESHOLD=${COVERAGE_THRESHOLD:-80}

# Check if coverage report exists
COVERAGE_FILE="coverage/coverage-summary.json"
if [ ! -f "$COVERAGE_FILE" ]; then
  echo "⚠️  Warning: Coverage report not found"
  echo "   Run 'npm run test:coverage' first"
  exit 0
fi

# Extract coverage percentages
LINES=$(cat "$COVERAGE_FILE" | grep -o '"lines":{"total":[0-9]*,"covered":[0-9]*' | grep -o '[0-9]*' | paste - - | awk '{if($1>0) print int($2*100/$1); else print 0}')
BRANCHES=$(cat "$COVERAGE_FILE" | grep -o '"branches":{"total":[0-9]*,"covered":[0-9]*' | grep -o '[0-9]*' | paste - - | awk '{if($1>0) print int($2*100/$1); else print 0}')
FUNCTIONS=$(cat "$COVERAGE_FILE" | grep -o '"functions":{"total":[0-9]*,"covered":[0-9]*' | grep -o '[0-9]*' | paste - - | awk '{if($1>0) print int($2*100/$1); else print 0}')
STATEMENTS=$(cat "$COVERAGE_FILE" | grep -o '"statements":{"total":[0-9]*,"covered":[0-9]*' | grep -o '[0-9]*' | paste - - | awk '{if($1>0) print int($2*100/$1); else print 0}')

echo "   Coverage Report:"
echo "   - Lines: $LINES%"
echo "   - Branches: $BRANCHES%"
echo "   - Functions: $FUNCTIONS%"
echo "   - Statements: $STATEMENTS%"
echo "   Threshold: $COVERAGE_THRESHOLD%"
echo ""

# Check if any metric is below threshold
FAILED=0
if [ "$LINES" -lt "$COVERAGE_THRESHOLD" ]; then
  echo "⚠️  Lines coverage ($LINES%) below threshold ($COVERAGE_THRESHOLD%)"
  FAILED=1
fi
if [ "$BRANCHES" -lt "$COVERAGE_THRESHOLD" ]; then
  echo "⚠️  Branches coverage ($BRANCHES%) below threshold ($COVERAGE_THRESHOLD%)"
  FAILED=1
fi
if [ "$FUNCTIONS" -lt "$COVERAGE_THRESHOLD" ]; then
  echo "⚠️  Functions coverage ($FUNCTIONS%) below threshold ($COVERAGE_THRESHOLD%)"
  FAILED=1
fi
if [ "$STATEMENTS" -lt "$COVERAGE_THRESHOLD" ]; then
  echo "⚠️  Statements coverage ($STATEMENTS%) below threshold ($COVERAGE_THRESHOLD%)"
  FAILED=1
fi

if [ "$FAILED" -eq 1 ]; then
  echo ""
  echo "Recommendations:"
  echo "   - Add more tests for uncovered code"
  echo "   - Focus on edge cases and error paths"
  echo "   - Review coverage report: open coverage/lcov-report/index.html"
  echo ""
  exit 1
fi

echo "✅ Code coverage passed"
echo "   All metrics above $COVERAGE_THRESHOLD%"
echo ""
exit 0
