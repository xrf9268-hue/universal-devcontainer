#!/bin/bash
# Install Git hooks for the repository

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
HOOKS_DIR="$REPO_ROOT/.git/hooks"

echo "Installing Git hooks..."
echo ""

# Check if we're in a git repository
if [ ! -d "$REPO_ROOT/.git" ]; then
    echo "Error: Not in a Git repository"
    echo "Please run this from the repository root"
    exit 1
fi

# Create hooks directory if it doesn't exist
mkdir -p "$HOOKS_DIR"

# Install pre-commit hook
if [ -f "$HOOKS_DIR/pre-commit" ]; then
    echo "⚠️  Pre-commit hook already exists"
    read -p "Replace existing hook? [y/N]: " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Skipping pre-commit hook installation"
    else
        ln -sf "../../scripts/pre-commit-hook.sh" "$HOOKS_DIR/pre-commit"
        echo "✅ Pre-commit hook installed (replaced existing)"
    fi
else
    ln -sf "../../scripts/pre-commit-hook.sh" "$HOOKS_DIR/pre-commit"
    echo "✅ Pre-commit hook installed"
fi

echo ""
echo "Git hooks installed successfully!"
echo ""
echo "The pre-commit hook will:"
echo "  • Validate JSON files with jq"
echo "  • Check shell script syntax with bash -n"
echo "  • Run ShellCheck (if available)"
echo "  • Check for TODO/FIXME markers"
echo "  • Detect potential secrets"
echo "  • Check for large files"
echo ""
echo "To bypass hooks for a specific commit (not recommended):"
echo "  git commit --no-verify"
