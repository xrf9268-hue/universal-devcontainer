#!/usr/bin/env bash
set -euo pipefail

# Remove local devcontainer override that binds an external project
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OVERRIDE_FILE="$REPO_ROOT/.devcontainer/devcontainer.local.json"

if [[ -f "$OVERRIDE_FILE" ]]; then
  rm -f "$OVERRIDE_FILE"
  echo "[universal-devcontainer] Removed override: $OVERRIDE_FILE"
  echo "Hint: If you used fallback mode, run 'Dev Containers: Reopen in Container' to reapply."
else
  echo "[universal-devcontainer] No override found at: $OVERRIDE_FILE"
  echo "Note: When using Dev Containers CLI, overrides are not needed."
fi
