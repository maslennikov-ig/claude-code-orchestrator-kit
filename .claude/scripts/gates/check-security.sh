#!/bin/bash
# Custom Quality Gate: Security Audit
# Purpose: Check for high/critical vulnerabilities in dependencies
# Blocking: true (must fix before merging)

set -e

echo "🔍 Running security audit..."

# Check if package.json exists
if [ ! -f "package.json" ]; then
  echo "⚠️  Warning: package.json not found"
  echo "   Skipping security audit"
  exit 0
fi

# Run npm audit for high/critical vulnerabilities
echo "   Checking for high/critical vulnerabilities..."
echo ""

if npm audit --audit-level=high --json > /tmp/audit-results.json 2>&1; then
  VULN_COUNT=$(cat /tmp/audit-results.json | grep -o '"total":[0-9]*' | head -1 | grep -o '[0-9]*' || echo "0")

  echo "✅ Security audit passed"
  echo "   No high/critical vulnerabilities found"
  echo ""
  rm -f /tmp/audit-results.json
  exit 0
else
  # Parse results
  VULN_COUNT=$(cat /tmp/audit-results.json | grep -o '"total":[0-9]*' | head -1 | grep -o '[0-9]*' || echo "unknown")

  echo "⛔ Security audit FAILED"
  echo "   Found $VULN_COUNT high/critical vulnerabilities"
  echo ""
  echo "Details:"
  npm audit --audit-level=high
  echo ""
  echo "To fix:"
  echo "   - Run: npm audit fix"
  echo "   - Or manually update affected packages"
  echo "   - Re-run security audit after fixes"
  echo ""
  rm -f /tmp/audit-results.json
  exit 1
fi
