#!/usr/bin/env bash
set -euo pipefail

# Claude Code Advanced Plugins Feature Installation Script
# Installs community plugins from xrf9268-hue/claude-code-plugins marketplace

echo "[claude-code-plugins] Starting installation..."

# Feature options (passed by Dev Container)
INSTALL_PLUGINS="${INSTALLPLUGINS:-essential}"
CUSTOM_PLUGINS="${CUSTOMPLUGINS:-}"
ADD_MARKETPLACE="${ADDMARKETPLACE:-true}"
REPLACE_DEFAULT="${REPLACEDEFAULTPLUGINS:-false}"

# Claude configuration paths
CLAUDE_HOME="${HOME}/.claude"
CLAUDE_SETTINGS="${CLAUDE_HOME}/settings.json"

# Ensure Claude Code is installed
if ! command -v claude &> /dev/null; then
    echo "[claude-code-plugins] ERROR: Claude Code CLI not found. Install 'claude-code' feature first."
    exit 1
fi

# Ensure settings.json exists
if [[ ! -f "$CLAUDE_SETTINGS" ]]; then
    echo "[claude-code-plugins] ERROR: Claude settings not found at $CLAUDE_SETTINGS"
    echo "[claude-code-plugins] Run 'claude-code' feature first to initialize Claude."
    exit 1
fi

echo "[claude-code-plugins] Claude Code found, proceeding with plugin installation..."

# Define plugin sets
declare -A PLUGIN_SETS=(
    ["essential"]="commit-commands,code-review,security-guidance,context-preservation"
    ["all"]="agent-sdk-dev,commit-commands,code-review,feature-dev,security-guidance,context-preservation,frontend-dev-guidelines,pr-review-toolkit,plugin-developer-toolkit"
    ["development"]="agent-sdk-dev,feature-dev,plugin-developer-toolkit"
    ["review"]="code-review,pr-review-toolkit"
    ["security"]="security-guidance"
    ["custom"]="${CUSTOM_PLUGINS}"
    ["none"]=""
)

# Get the plugin list to install
PLUGINS_TO_INSTALL="${PLUGIN_SETS[$INSTALL_PLUGINS]:-}"

if [[ "$INSTALL_PLUGINS" == "custom" && -z "$CUSTOM_PLUGINS" ]]; then
    echo "[claude-code-plugins] WARNING: 'custom' selected but customPlugins is empty. No plugins will be installed."
    PLUGINS_TO_INSTALL=""
fi

echo "[claude-code-plugins] Installation mode: $INSTALL_PLUGINS"
if [[ -n "$PLUGINS_TO_INSTALL" ]]; then
    echo "[claude-code-plugins] Plugins to install: $PLUGINS_TO_INSTALL"
else
    echo "[claude-code-plugins] No plugins will be installed (only marketplace will be added)"
fi

# Step 1: Add marketplace to settings.json
if [[ "$ADD_MARKETPLACE" == "true" ]]; then
    echo "[claude-code-plugins] Adding community marketplace to Claude settings..."

    # Create marketplace configuration
    MARKETPLACE_JSON=$(cat <<'EOF'
{
  "community-plugins": {
    "source": {
      "github": {
        "repo": "xrf9268-hue/claude-code-plugins",
        "path": "plugins"
      }
    }
  }
}
EOF
)

    # Merge marketplace into extraKnownMarketplaces
    tmp_file=$(mktemp)
    jq --argjson marketplace "$MARKETPLACE_JSON" \
        '.extraKnownMarketplaces = (.extraKnownMarketplaces // {}) + $marketplace' \
        "$CLAUDE_SETTINGS" > "$tmp_file"
    mv "$tmp_file" "$CLAUDE_SETTINGS"

    echo "[claude-code-plugins] ✓ Community marketplace added"
else
    echo "[claude-code-plugins] Skipping marketplace addition (addMarketplace=false)"
fi

# Step 2: Install plugins
if [[ -n "$PLUGINS_TO_INSTALL" ]]; then
    echo "[claude-code-plugins] Enabling plugins..."

    # Build enabledPlugins JSON
    ENABLED_PLUGINS_JSON="{"
    IFS=',' read -ra PLUGIN_ARRAY <<< "$PLUGINS_TO_INSTALL"
    for i in "${!PLUGIN_ARRAY[@]}"; do
        plugin="${PLUGIN_ARRAY[$i]}"
        # Trim whitespace
        plugin=$(echo "$plugin" | xargs)

        if [[ -n "$plugin" ]]; then
            [[ $i -gt 0 ]] && ENABLED_PLUGINS_JSON+=","
            ENABLED_PLUGINS_JSON+="\"${plugin}@community-plugins\":true"
            echo "  - $plugin"
        fi
    done
    ENABLED_PLUGINS_JSON+="}"

    # Merge plugins into settings
    tmp_file=$(mktemp)

    if [[ "$REPLACE_DEFAULT" == "true" ]]; then
        echo "[claude-code-plugins] Replacing default plugins with community plugins..."
        jq --argjson plugins "$ENABLED_PLUGINS_JSON" \
            '.enabledPlugins = $plugins' \
            "$CLAUDE_SETTINGS" > "$tmp_file"
    else
        echo "[claude-code-plugins] Merging with existing plugins..."
        jq --argjson plugins "$ENABLED_PLUGINS_JSON" \
            '.enabledPlugins = (.enabledPlugins // {}) + $plugins' \
            "$CLAUDE_SETTINGS" > "$tmp_file"
    fi

    mv "$tmp_file" "$CLAUDE_SETTINGS"
    echo "[claude-code-plugins] ✓ Plugins enabled"
else
    echo "[claude-code-plugins] No plugins to enable"
fi

# Step 3: Verify installation
echo "[claude-code-plugins] Verifying installation..."

if command -v jq &> /dev/null; then
    echo ""
    echo "=== Installed Marketplaces ==="
    jq -r '.extraKnownMarketplaces | keys[]' "$CLAUDE_SETTINGS" 2>/dev/null || echo "  (none)"

    echo ""
    echo "=== Enabled Plugins ==="
    jq -r '.enabledPlugins | keys[]' "$CLAUDE_SETTINGS" 2>/dev/null || echo "  (none)"
    echo ""
fi

# Step 4: Print summary
echo "[claude-code-plugins] ✓ Installation complete!"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Claude Code Advanced Plugins - Installation Summary"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Mode: $INSTALL_PLUGINS"
echo "  Marketplace: $([ "$ADD_MARKETPLACE" == "true" ] && echo "✓ Added" || echo "✗ Skipped")"
echo "  Plugins: $([ -n "$PLUGINS_TO_INSTALL" ] && echo "$PLUGINS_TO_INSTALL" || echo "none")"
echo "  Replace defaults: $([ "$REPLACE_DEFAULT" == "true" ] && echo "yes" || echo "no")"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Next steps:"
echo "  1. Rebuild your container or run: source ~/.bashrc"
echo "  2. Verify: claude /doctor"
echo "  3. List plugins: claude /plugins list"
echo "  4. Explore: claude /help"
echo ""
echo "Available plugins from community marketplace:"
echo "  • agent-sdk-dev - Claude Agent SDK development tools"
echo "  • commit-commands - Git workflow automation (/commit, /commit-push-pr)"
echo "  • code-review - Automated PR review with confidence scoring"
echo "  • feature-dev - 7-phase structured feature development"
echo "  • security-guidance - Proactive security warnings (17 rules)"
echo "  • context-preservation - Auto-save context before compaction"
echo "  • frontend-dev-guidelines - React/TypeScript best practices"
echo "  • pr-review-toolkit - 6 specialized review agents"
echo "  • plugin-developer-toolkit - Create your own plugins"
echo ""
echo "Documentation: https://github.com/xrf9268-hue/claude-code-plugins"
echo ""

exit 0
