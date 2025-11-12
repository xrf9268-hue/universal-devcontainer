#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 1 ]]; then
  cat <<EOF
Usage: $0 <path|git-url>

Opens the universal-devcontainer with your project mounted inside.

Examples:
  $0 /path/to/your/project
  $0 .
  $0 https://github.com/owner/repo.git

How it works:
  1. Sets PROJECT_PATH environment variable
  2. Opens universal-devcontainer in VS Code
  3. Container mounts your project at /workspace
EOF
  exit 1
fi

# Resolve project directory (support Git URLs by shallow clone)
if [[ "$1" =~ ^https?://|git@ ]]; then
  TMP="${HOME}/.cache/universal-dev/$(date +%s)"
  mkdir -p "$(dirname "$TMP")"
  echo "Cloning $1 to temporary directory..."
  git clone --depth=1 "$1" "$TMP"
  PROJECT_DIR="$TMP"
else
  PROJECT_DIR="$(cd "$1" && pwd)"
fi

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PROJ_NAME="$(basename "$PROJECT_DIR")"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Universal Dev Container - Project Setup"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Project:    $PROJ_NAME"
echo "  Path:       $PROJECT_DIR"
echo "  DevContainer: $REPO_ROOT"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Export PROJECT_PATH for VS Code to pick up
export PROJECT_PATH="$PROJECT_DIR"

echo "✓ Setting PROJECT_PATH=$PROJECT_DIR"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Next Steps:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  1. Opening universal-devcontainer in VS Code..."
echo "  2. When prompted, click 'Reopen in Container'"
echo "  3. Your project will be mounted at /workspace"
echo ""
echo "  Note: Set these environment variables before running:"
echo "    export CLAUDE_LOGIN_METHOD=console"
echo "    export ANTHROPIC_API_KEY=sk-ant-..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

exec code "$REPO_ROOT"
