#!/usr/bin/env bash
set -euo pipefail

# Ensure the named volume mounted at /home/<user>/.claude is owned by the dev user
TARGET_USER="${SUDO_USER:-$USER}"
USER_HOME="$(eval echo ~"$TARGET_USER")"
CLAUDE_DIR="$USER_HOME/.claude"

mkdir -p "$CLAUDE_DIR"

UID_NUM="$(id -u "$TARGET_USER")"
GID_NUM="$(id -g "$TARGET_USER")"

chown -R "$UID_NUM":"$GID_NUM" "$CLAUDE_DIR" || true
chmod 700 "$CLAUDE_DIR" || true

mkdir -p "$CLAUDE_DIR/bin" "$CLAUDE_DIR/commands" "$CLAUDE_DIR/skills" "$CLAUDE_DIR/debug"
chown -R "$UID_NUM":"$GID_NUM" "$CLAUDE_DIR" || true

echo "[fix-claude-home] Ensured ownership of $CLAUDE_DIR for $TARGET_USER ($UID_NUM:$GID_NUM)"

