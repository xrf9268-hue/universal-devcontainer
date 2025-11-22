#!/bin/bash
# scripts/validate-all.sh
# Validate all project configurations

set -e

echo "🔍 Validating universal-devcontainer configurations..."
echo ""

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Track errors
ERRORS=0

# JSON validation
echo "📋 Validating JSON files..."
for json_file in .devcontainer/devcontainer.json .claude/settings.local.json; do
  if [ -f "$json_file" ]; then
    if jq empty "$json_file" 2>/dev/null; then
      echo -e "  ${GREEN}✓${NC} $json_file"
    else
      echo -e "  ${RED}✗${NC} $json_file - Invalid JSON"
      ERRORS=$((ERRORS + 1))
    fi
  else
    echo -e "  ${YELLOW}⚠${NC} $json_file - Not found"
  fi
done
echo ""

# Shell script syntax validation
echo "🐚 Validating shell scripts..."
for script in scripts/*.sh .devcontainer/*.sh; do
  if [ -f "$script" ]; then
    if bash -n "$script" 2>/dev/null; then
      echo -e "  ${GREEN}✓${NC} $script"
    else
      echo -e "  ${RED}✗${NC} $script - Syntax error"
      ERRORS=$((ERRORS + 1))
    fi
  fi
done
echo ""

# Shellcheck (if available)
if command -v shellcheck &> /dev/null; then
  echo "🔍 Running shellcheck..."
  for script in scripts/*.sh .devcontainer/*.sh; do
    if [ -f "$script" ]; then
      if shellcheck "$script" 2>/dev/null; then
        echo -e "  ${GREEN}✓${NC} $script"
      else
        echo -e "  ${YELLOW}⚠${NC} $script - Has warnings (non-critical)"
      fi
    fi
  done
  echo ""
else
  echo -e "${YELLOW}⚠ shellcheck not installed, skipping static analysis${NC}"
  echo "  Install with: apt-get install shellcheck"
  echo ""
fi

# File permissions check
echo "🔒 Checking file permissions..."
for script in scripts/*.sh .devcontainer/*.sh; do
  if [ -f "$script" ]; then
    if [ -x "$script" ]; then
      echo -e "  ${GREEN}✓${NC} $script - executable"
    else
      echo -e "  ${YELLOW}⚠${NC} $script - not executable (fixing...)"
      chmod +x "$script"
      echo -e "  ${GREEN}✓${NC} $script - fixed"
    fi
  fi
done
echo ""

# Check for common issues
echo "🔎 Checking for common issues..."

# Check for secrets in code
if git ls-files | xargs grep -i -E "api_key|password|secret|token" | grep -v -E "\.md$|settings\.local\.json|IMPLEMENTATION|TODO" > /dev/null 2>&1; then
  echo -e "  ${YELLOW}⚠${NC} Found potential secrets in code (review needed)"
  ERRORS=$((ERRORS + 1))
else
  echo -e "  ${GREEN}✓${NC} No obvious secrets found"
fi

# Check for required files
REQUIRED_FILES=(
  "README.md"
  ".devcontainer/devcontainer.json"
  ".devcontainer/bootstrap-claude.sh"
  "scripts/open-project.sh"
  "LICENSE"
)

for file in "${REQUIRED_FILES[@]}"; do
  if [ -f "$file" ]; then
    echo -e "  ${GREEN}✓${NC} $file exists"
  else
    echo -e "  ${RED}✗${NC} $file missing"
    ERRORS=$((ERRORS + 1))
  fi
done
echo ""

# Summary
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
if [ $ERRORS -eq 0 ]; then
  echo -e "${GREEN}✅ All validations passed!${NC}"
  exit 0
else
  echo -e "${RED}❌ Found $ERRORS error(s)${NC}"
  exit 1
fi
