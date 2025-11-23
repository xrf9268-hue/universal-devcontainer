# Example: Project with Advanced Claude Code Plugins

> **⭐ Recommended Standard**: This configuration is now the **recommended best practice** for all projects using Claude Code. Community plugins provide enhanced features compared to official plugins.

This example demonstrates how to use the `claude-code-plugins` dev container feature to install advanced community plugins for Claude Code.

## What's Included

This dev container includes:
- ✅ **Claude Code** with host login method
- ✅ **Advanced Plugins** (essential set):
  - `commit-commands` - Git workflow automation
  - `code-review` - Automated PR review
  - `security-guidance` - Security validation
  - `context-preservation` - Context auto-save
- ✅ **Node.js LTS** and **Python 3.12**
- ✅ **GitHub CLI** for PR management

## Quick Start

### Option 1: Use This Example Directly

```bash
# Clone the repository
git clone https://github.com/xrf9268-hue/universal-devcontainer.git
cd universal-devcontainer/examples/with-advanced-plugins

# Open in VS Code
code .

# Reopen in Container
# (VS Code will prompt, or use Command Palette > Dev Containers: Reopen in Container)
```

### Option 2: Copy to Your Project

Copy `.devcontainer/devcontainer.json` to your project:

```bash
cp -r .devcontainer /path/to/your/project/
cd /path/to/your/project
code .
```

## Verifying Installation

Once the container is built and running:

```bash
# Check Claude Code status
claude /doctor

# List available marketplaces
claude /plugins marketplaces
# Expected output includes: community-plugins

# List installed plugins
claude /plugins list
# Expected output includes: commit-commands, code-review, security-guidance, context-preservation

# Test a plugin command
claude /commit --help
```

## Using the Plugins

### commit-commands

Automate git workflows:

```bash
# Create a commit with AI-generated message
claude /commit

# Commit, push, and create PR in one command
claude /commit-push-pr

# Clean up stale branches
claude /clean_gone
```

### code-review

Automated PR review:

```bash
# Review a pull request
claude /code-review 123

# The plugin will:
# - Fetch PR details
# - Analyze changes with multiple specialized agents
# - Provide confidence scores (≥80% threshold)
# - Generate actionable review comments
```

### security-guidance

Proactive security warnings (automatic via PreToolUse hook):

```bash
# When Claude suggests code, the plugin automatically:
# - Checks for XSS vulnerabilities
# - Detects command injection risks
# - Warns about unsafe patterns
# - Validates input sanitization
```

### context-preservation

Auto-save context (automatic via PreCompact hook):

```bash
# Before conversation history compaction, automatically saves:
# - Architecture decisions
# - Debugging insights
# - Design rationales
# - Important context

# No manual action needed - works automatically!
```

## Customizing Plugin Selection

Edit `.devcontainer/devcontainer.json` to change plugins:

### Use All Plugins

```json
{
  "features": {
    "ghcr.io/xrf9268-hue/features/claude-code-plugins:1": {
      "installPlugins": "all"
    }
  }
}
```

### Custom Selection

```json
{
  "features": {
    "ghcr.io/xrf9268-hue/features/claude-code-plugins:1": {
      "installPlugins": "custom",
      "customPlugins": "commit-commands,feature-dev,frontend-dev-guidelines"
    }
  }
}
```

### Development Focus

```json
{
  "features": {
    "ghcr.io/xrf9268-hue/features/claude-code-plugins:1": {
      "installPlugins": "development"
    }
  }
}
```

## Plugin Sets Available

| Set | Plugins | Best For |
|-----|---------|----------|
| **essential** (default) | commit-commands, code-review, security-guidance, context-preservation | Most users |
| **all** | All 9 plugins | Power users |
| **development** | agent-sdk-dev, feature-dev, plugin-developer-toolkit | SDK/plugin developers |
| **review** | code-review, pr-review-toolkit | Code review focus |
| **security** | security-guidance | Security-conscious projects |
| **custom** | Your choice | Specific needs |
| **none** | Marketplace only | Manual management |

## Available Plugins

1. **agent-sdk-dev** - Claude Agent SDK development tools
2. **commit-commands** - Git workflow automation
3. **code-review** - Automated PR review with confidence scoring
4. **feature-dev** - 7-phase structured feature development
5. **security-guidance** - Proactive security warnings
6. **context-preservation** - Auto-save context before compaction
7. **frontend-dev-guidelines** - React/TypeScript best practices
8. **pr-review-toolkit** - 6 specialized review agents
9. **plugin-developer-toolkit** - Create your own plugins

## Troubleshooting

### Plugins not showing up

```bash
# Check settings
cat ~/.claude/settings.json | jq .enabledPlugins

# Verify marketplace
cat ~/.claude/settings.json | jq .extraKnownMarketplaces

# Rebuild container
# Command Palette > Dev Containers: Rebuild Container
```

### Feature installation errors

Check that `claude-code` feature is listed **before** `claude-code-plugins`:

```json
{
  "features": {
    "ghcr.io/xrf9268-hue/features/claude-code:1": {},
    "ghcr.io/xrf9268-hue/features/claude-code-plugins:1": {}
  }
}
```

## Learn More

- **Plugin Repository**: https://github.com/xrf9268-hue/claude-code-plugins
- **Feature Documentation**: [../../src/features/claude-code-plugins/README.md](../../src/features/claude-code-plugins/README.md)
- **Claude Code Docs**: https://code.claude.com/docs

## License

MIT License
