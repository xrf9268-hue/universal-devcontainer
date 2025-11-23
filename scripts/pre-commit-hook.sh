#!/bin/bash
# Pre-commit hook for validating changes
# Install: ln -sf ../../scripts/pre-commit-hook.sh .git/hooks/pre-commit

set -e

echo "🔍 Running pre-commit validations..."
echo ""

# Track validation status
VALIDATION_FAILED=0

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Get list of staged files
STAGED_FILES=$(git diff --cached --name-only --diff-filter=ACM)

# Validate JSON files
echo "📋 Validating JSON files..."
JSON_FILES=$(echo "$STAGED_FILES" | grep '\.json$' || true)
if [ -n "$JSON_FILES" ]; then
    JSON_VALID=true
    while IFS= read -r file; do
        if [ -f "$file" ]; then
            if ! jq empty "$file" 2>/dev/null; then
                echo -e "${RED}✗ Invalid JSON: $file${NC}"
                JSON_VALID=false
                VALIDATION_FAILED=1
            else
                echo -e "${GREEN}✓ Valid: $file${NC}"
            fi
        fi
    done <<< "$JSON_FILES"

    if [ "$JSON_VALID" = true ]; then
        echo -e "${GREEN}✓ All JSON files are valid${NC}"
    fi
else
    echo "  No JSON files to validate"
fi
echo ""

# Validate shell scripts
echo "🔧 Validating shell scripts..."
SHELL_FILES=$(echo "$STAGED_FILES" | grep '\.sh$' || true)
if [ -n "$SHELL_FILES" ]; then
    SHELL_VALID=true
    while IFS= read -r file; do
        if [ -f "$file" ]; then
            # Check syntax
            if ! bash -n "$file" 2>/dev/null; then
                echo -e "${RED}✗ Syntax error: $file${NC}"
                SHELL_VALID=false
                VALIDATION_FAILED=1
            else
                echo -e "${GREEN}✓ Valid syntax: $file${NC}"
            fi

            # Check for bash shebang
            if ! head -n 1 "$file" | grep -q '^#!/bin/bash'; then
                echo -e "${YELLOW}⚠ Missing or incorrect shebang: $file${NC}"
                echo -e "${YELLOW}  Expected: #!/bin/bash${NC}"
            fi
        fi
    done <<< "$SHELL_FILES"

    if [ "$SHELL_VALID" = true ]; then
        echo -e "${GREEN}✓ All shell scripts have valid syntax${NC}"
    fi
else
    echo "  No shell scripts to validate"
fi
echo ""

# Run ShellCheck if available
if command -v shellcheck &> /dev/null; then
    echo "🔬 Running ShellCheck..."
    if [ -n "$SHELL_FILES" ]; then
        SHELLCHECK_FAILED=false
        while IFS= read -r file; do
            if [ -f "$file" ]; then
                if ! shellcheck "$file"; then
                    echo -e "${YELLOW}⚠ ShellCheck warnings: $file${NC}"
                    SHELLCHECK_FAILED=true
                    # Note: We don't fail the commit on ShellCheck warnings
                fi
            fi
        done <<< "$SHELL_FILES"

        if [ "$SHELLCHECK_FAILED" = false ]; then
            echo -e "${GREEN}✓ All shell scripts pass ShellCheck${NC}"
        else
            echo -e "${YELLOW}⚠ Some ShellCheck warnings found (not blocking commit)${NC}"
        fi
    else
        echo "  No shell scripts to check"
    fi
else
    echo -e "${YELLOW}⚠ ShellCheck not installed, skipping${NC}"
fi
echo ""

# Check for common issues
echo "🔎 Checking for common issues..."

# Check for TODO markers in code
TODO_FILES=$(echo "$STAGED_FILES" | xargs grep -l "TODO\|FIXME\|XXX" 2>/dev/null || true)
if [ -n "$TODO_FILES" ]; then
    echo -e "${YELLOW}⚠ Found TODO/FIXME/XXX markers in:${NC}"
    echo "$TODO_FILES" | sed 's/^/  /'
    echo ""
fi

# Check for secrets patterns
SECRETS_PATTERNS=(
    'api[_-]?key'
    'password\s*='
    'secret[_-]?key'
    'bearer\s+[a-zA-Z0-9]'
    'token\s*='
    'private[_-]?key'
)

SECRETS_FOUND=false
for pattern in "${SECRETS_PATTERNS[@]}"; do
    SECRET_MATCHES=$(echo "$STAGED_FILES" | xargs grep -iE "$pattern" 2>/dev/null || true)
    if [ -n "$SECRET_MATCHES" ]; then
        if [ "$SECRETS_FOUND" = false ]; then
            echo -e "${RED}⚠ Potential secrets detected:${NC}"
            SECRETS_FOUND=true
        fi
        echo -e "${RED}  Pattern '$pattern':${NC}"
        echo "$SECRET_MATCHES" | sed 's/^/    /'
    fi
done

if [ "$SECRETS_FOUND" = true ]; then
    echo ""
    echo -e "${RED}Please review these files to ensure no secrets are committed${NC}"
    read -p "Continue with commit? [y/N]: " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Commit aborted"
        exit 1
    fi
fi

# Check for large files
echo "📦 Checking file sizes..."
LARGE_FILES=$(echo "$STAGED_FILES" | while read -r file; do
    if [ -f "$file" ]; then
        size=$(stat -f%z "$file" 2>/dev/null || stat -c%s "$file" 2>/dev/null || echo 0)
        if [ "$size" -gt 1048576 ]; then  # 1MB
            echo "$file ($(numfmt --to=iec-i --suffix=B $size 2>/dev/null || echo $size bytes))"
        fi
    fi
done)

if [ -n "$LARGE_FILES" ]; then
    echo -e "${YELLOW}⚠ Large files detected (>1MB):${NC}"
    echo "$LARGE_FILES" | sed 's/^/  /'
    echo ""
    read -p "Continue with commit? [y/N]: " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Commit aborted"
        exit 1
    fi
fi

# Summary
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
if [ $VALIDATION_FAILED -eq 0 ]; then
    echo -e "${GREEN}✓ All validations passed!${NC}"
    echo ""
    exit 0
else
    echo -e "${RED}✗ Some validations failed${NC}"
    echo ""
    echo "Please fix the errors above before committing."
    exit 1
fi
