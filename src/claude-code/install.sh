#!/usr/bin/env bash
set -euo pipefail

# Feature options (automatically uppercased by Dev Container CLI)
LOGIN_METHOD="${LOGINMETHOD:-host}"
BYPASS_PERMS="${BYPASSPERMISSIONS:-true}"
PLUGINS="${INSTALLPLUGINS:-}"
ENABLE_SANDBOX="${ENABLESANDBOX:-false}"
ORG_UUID="${ORGUUID:-}"

echo "[claude-code-feature] Installing Claude Code CLI..."

# Install Claude Code globally
# Pin to stable 1.x series (allows minor/patch updates)
# For exact version pinning, use: npm install -g @anthropic-ai/claude-code@1.0.58
# To get latest version: npm view @anthropic-ai/claude-code version
npm install -g @anthropic-ai/claude-code@^1.0.0

# Determine target user (respect _REMOTE_USER or default to vscode)
TARGET_USER="${_REMOTE_USER:-vscode}"
TARGET_HOME=$(eval echo ~"$TARGET_USER")
CLAUDE_HOME="$TARGET_HOME/.claude"

echo "[claude-code-feature] Setting up Claude config at $CLAUDE_HOME for user: $TARGET_USER"
mkdir -p "$CLAUDE_HOME/bin" "$CLAUDE_HOME/commands" "$CLAUDE_HOME/skills"

# Determine permission mode
if [[ "$BYPASS_PERMS" = "true" ]]; then
  PERM_MODE="bypassPermissions"
else
  PERM_MODE="requireApproval"
fi

# Build base configuration
echo "[claude-code-feature] Creating base settings (permission mode: $PERM_MODE)..."

BASE_CFG=$(cat <<JSON
{
  "permissions": {
    "deny": [
      "Read(./.env)",
      "Read(./.env.*)",
      "Read(./secrets/**)",
      "Read(**/id_rsa)",
      "Read(**/id_ed25519)"
    ],
    "defaultMode": "$PERM_MODE"
  },
  "extraKnownMarketplaces": {
    "claude-code-plugins": {
      "source": {
        "github": { "repo": "anthropics/claude-code", "path": "plugins" }
      }
    }
  }
}
JSON
)

# Add enabled plugins
if [[ -n "$PLUGINS" ]]; then
  echo "[claude-code-feature] Enabling plugins: $PLUGINS"
  PLUGIN_JSON="{"
  IFS=',' read -ra PLUGIN_ARRAY <<< "$PLUGINS"
  for i in "${!PLUGIN_ARRAY[@]}"; do
    plugin="${PLUGIN_ARRAY[$i]}"
    [[ $i -gt 0 ]] && PLUGIN_JSON+=","
    PLUGIN_JSON+="\"${plugin}@claude-code-plugins\":true"
  done
  PLUGIN_JSON+="}"

  BASE_CFG=$(echo "$BASE_CFG" | jq --argjson plugins "$PLUGIN_JSON" '.enabledPlugins = $plugins')
fi

# Configure login method
if [[ "$LOGIN_METHOD" = "host" ]]; then
  echo "[claude-code-feature] Login method: host (will import from /host-claude)"
  # Import will happen at runtime via postCreateCommand
elif [[ "$LOGIN_METHOD" = "api-key" ]]; then
  echo "[claude-code-feature] Login method: api-key (requires ANTHROPIC_API_KEY env var)"
  # Create API key helper script
  cat > "$CLAUDE_HOME/bin/apikey.sh" <<'SH'
#!/usr/bin/env sh
[ -n "$ANTHROPIC_API_KEY" ] && { printf "%s" "$ANTHROPIC_API_KEY"; exit 0; }
echo "ANTHROPIC_API_KEY not set" >&2
exit 1
SH
  chmod 700 "$CLAUDE_HOME/bin/apikey.sh"
  BASE_CFG=$(echo "$BASE_CFG" | jq --arg path "$CLAUDE_HOME/bin/apikey.sh" '.apiKeyHelper = $path')
else
  echo "[claude-code-feature] Login method: manual (user must run 'claude login')"
fi

# Add organization UUID if provided
if [[ -n "$ORG_UUID" ]]; then
  echo "[claude-code-feature] Setting organization UUID: $ORG_UUID"
  BASE_CFG=$(echo "$BASE_CFG" | jq --arg org "$ORG_UUID" '.forceLoginOrgUUID = $org')
fi

# Add sandbox configuration
if [[ "$ENABLE_SANDBOX" = "true" ]]; then
  echo "[claude-code-feature] Enabling sandbox mode"
  BASE_CFG=$(echo "$BASE_CFG" | jq '.sandbox = {allowUnsandboxedCommands: false, enableWeakerNestedSandbox: true}')
fi

# Write final configuration
echo "$BASE_CFG" | jq '.' > "$CLAUDE_HOME/settings.json"

# Create example command
cat > "$CLAUDE_HOME/commands/review-pr.md" <<'CMD'
Analyze a GitHub PR and suggest actionable review points for $ARGUMENTS.
Use `gh pr view $ARGUMENTS --comments` to gather context; produce a concise checklist + suggested diffs.
CMD

# Create example skill
mkdir -p "$CLAUDE_HOME/skills/reviewing-prs"
cat > "$CLAUDE_HOME/skills/reviewing-prs/SKILL.md" <<'SK'
---
name: reviewing-prs
description: Provide concise review checklists and PR summaries.
---
Focus on correctness, security, performance, readability.
SK

# Create global notes
cat > "$CLAUDE_HOME/CLAUDE.md" <<'MD'
# Global notes for Claude Code
- Tools: bash, gh, node, python
- Conventions: src/, tests/, docs/
- Safety: do not read `.env*` or `secrets/**` unless explicitly asked
MD

# Set ownership
chown -R "$TARGET_USER:$TARGET_USER" "$CLAUDE_HOME" || true

# Create runtime import script for host login method
if [[ "$LOGIN_METHOD" = "host" ]]; then
  cat > "$CLAUDE_HOME/import-host-settings.sh" <<'IMPORT'
#!/usr/bin/env bash
set -euo pipefail
HOST_CFG="/host-claude/settings.json"
CONTAINER_CFG="$HOME/.claude/settings.json"

if [[ -f "$HOST_CFG" ]]; then
  echo "[claude-code] Importing settings from host..."
  # Merge host settings with container settings (container takes precedence for feature-configured options)
  tmp="$(mktemp)"
  jq -s '.[0] * .[1]' "$HOST_CFG" "$CONTAINER_CFG" > "$tmp" && mv "$tmp" "$CONTAINER_CFG"
  echo "[claude-code] Host settings imported successfully"
else
  echo "[claude-code] No host settings found at $HOST_CFG (this is OK if using api-key or manual method)"
fi
IMPORT
  chmod +x "$CLAUDE_HOME/import-host-settings.sh"
  chown "$TARGET_USER:$TARGET_USER" "$CLAUDE_HOME/import-host-settings.sh" || true
fi

echo "[claude-code-feature] ✅ Installation complete!"
echo "  - Permission mode: $PERM_MODE"
echo "  - Login method: $LOGIN_METHOD"
echo "  - Plugins: ${PLUGINS:-none (use claude-code-plugins feature for enhanced plugins)}"
[[ "$ENABLE_SANDBOX" = "true" ]] && echo "  - Sandbox: enabled"
[[ -n "$ORG_UUID" ]] && echo "  - Organization: $ORG_UUID"

# Print post-install instructions
cat <<'INSTRUCTIONS'

📝 Post-Install Notes:
======================

For 'host' login method:
  - Ensure /host-claude mount is configured in devcontainer.json
  - Run the import script in postCreateCommand:
    "postCreateCommand": "bash ~/.claude/import-host-settings.sh"

For 'api-key' method:
  - Set ANTHROPIC_API_KEY environment variable in devcontainer.json:
    "remoteEnv": { "ANTHROPIC_API_KEY": "${localEnv:ANTHROPIC_API_KEY}" }

For 'manual' method:
  - After container starts, run: claude login

To verify installation:
  - claude --version
  - cat ~/.claude/settings.json

INSTRUCTIONS
