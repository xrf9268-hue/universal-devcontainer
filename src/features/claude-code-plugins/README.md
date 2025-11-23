# Claude Code Advanced Plugins

Production-ready Claude Code plugins from the community marketplace with enhanced development workflows, code review, and security features.

## Description

This Dev Container Feature installs and configures advanced Claude Code plugins from the [xrf9268-hue/claude-code-plugins](https://github.com/xrf9268-hue/claude-code-plugins) community marketplace. These plugins extend Claude Code with specialized agents, commands, skills, and hooks for professional software development.

## Features

- 🔌 **9 Advanced Plugins** - From basic git automation to sophisticated code review
- 🎯 **Flexible Installation** - Choose preset plugin sets or customize your own
- 🔄 **Marketplace Integration** - Access the full community plugin ecosystem
- 🤝 **Compatible** - Works alongside official Claude Code plugins
- 📦 **Zero Dependencies** - Only requires Claude Code CLI (included in `claude-code` feature)

## Available Plugins

### Development Tools
- **agent-sdk-dev** - Streamlines Claude Agent SDK development with scaffolding commands and verification agents for Python/TypeScript
- **feature-dev** - Structured 7-phase feature development with explorer, architect, and reviewer agents
- **plugin-developer-toolkit** - Meta-plugin for creating your own Claude Code plugins with templates

### Code Review & Quality
- **code-review** - Automated PR review using specialized agents with confidence-based scoring (≥80% threshold)
- **pr-review-toolkit** - 6 specialized review agents: comment-analyzer, test-analyzer, silent-failure-hunter, type-design-analyzer, code-reviewer, code-simplifier

### Git & Workflow
- **commit-commands** - Simplifies git operations with `/commit`, `/commit-push-pr`, and `/clean_gone` commands

### Security
- **security-guidance** - Proactive security validation covering 17 rules for XSS, command injection, and unsafe patterns

### Context & Guidelines
- **context-preservation** - Automatically saves critical context before conversation history compaction
- **frontend-dev-guidelines** - Modular guidance for React/TypeScript: components, performance, accessibility, testing, state management

## Usage

### Basic Usage (Recommended)

Add to your `.devcontainer/devcontainer.json`:

```json
{
  "features": {
    "ghcr.io/xrf9268-hue/features/claude-code:1": {
      "loginMethod": "host"
    },
    "ghcr.io/xrf9268-hue/features/claude-code-plugins:1": {
      "installPlugins": "essential"
    }
  }
}
```

### Plugin Sets

Choose from predefined plugin sets:

#### Essential (Default) ⭐
**Best for**: Most users, balanced feature set
```json
{
  "installPlugins": "essential"
}
```
**Includes**: commit-commands, code-review, security-guidance, context-preservation

#### All Plugins
**Best for**: Power users who want everything
```json
{
  "installPlugins": "all"
}
```
**Includes**: All 9 plugins

#### Development Focus
**Best for**: SDK and plugin developers
```json
{
  "installPlugins": "development"
}
```
**Includes**: agent-sdk-dev, feature-dev, plugin-developer-toolkit

#### Review Focus
**Best for**: Code review and quality assurance
```json
{
  "installPlugins": "review"
}
```
**Includes**: code-review, pr-review-toolkit

#### Security Focus
**Best for**: Security-conscious projects
```json
{
  "installPlugins": "security"
}
```
**Includes**: security-guidance

#### Custom Selection
**Best for**: Specific plugin combinations
```json
{
  "installPlugins": "custom",
  "customPlugins": "commit-commands,feature-dev,security-guidance"
}
```

#### Marketplace Only
**Best for**: Manual plugin management
```json
{
  "installPlugins": "none"
}
```
**Note**: Adds marketplace but doesn't install any plugins automatically

## Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `installPlugins` | string | `essential` | Plugin set: `essential`, `all`, `development`, `review`, `security`, `custom`, `none` |
| `customPlugins` | string | `""` | Comma-separated plugin names for `custom` mode |
| `addMarketplace` | boolean | `true` | Add community marketplace to Claude settings |
| `replaceDefaultPlugins` | boolean | `false` | Replace official plugins with community ones (not recommended) |

## Examples

### Example 1: Essential Plugins (Recommended)

```json
{
  "name": "My Project",
  "features": {
    "ghcr.io/xrf9268-hue/features/claude-code:1": {},
    "ghcr.io/xrf9268-hue/features/claude-code-plugins:1": {
      "installPlugins": "essential"
    }
  }
}
```

### Example 2: Full Stack Development

```json
{
  "name": "Full Stack App",
  "features": {
    "ghcr.io/xrf9268-hue/features/claude-code:1": {
      "loginMethod": "host"
    },
    "ghcr.io/xrf9268-hue/features/claude-code-plugins:1": {
      "installPlugins": "custom",
      "customPlugins": "commit-commands,feature-dev,code-review,frontend-dev-guidelines,security-guidance"
    }
  }
}
```

### Example 3: Security Audit Project

```json
{
  "name": "Security Audit",
  "features": {
    "ghcr.io/xrf9268-hue/features/claude-code:1": {},
    "ghcr.io/xrf9268-hue/features/claude-code-plugins:1": {
      "installPlugins": "custom",
      "customPlugins": "security-guidance,code-review,pr-review-toolkit"
    }
  }
}
```

### Example 4: Plugin Developer Setup

```json
{
  "name": "Plugin Development",
  "features": {
    "ghcr.io/xrf9268-hue/features/claude-code:1": {},
    "ghcr.io/xrf9268-hue/features/claude-code-plugins:1": {
      "installPlugins": "development"
    }
  }
}
```

### Example 5: Community Plugins Only (Recommended)

```json
{
  "features": {
    "ghcr.io/xrf9268-hue/features/claude-code:1": {
      "loginMethod": "host"
      // Note: installPlugins defaults to "" (no official plugins)
    },
    "ghcr.io/xrf9268-hue/features/claude-code-plugins:1": {
      "installPlugins": "custom",
      "customPlugins": "feature-dev,context-preservation,frontend-dev-guidelines"
    }
  }
}
```

## Why Use Community Plugins Instead of Official?

The community plugins are **enhanced versions** of the official plugins with significantly more features:

| Plugin | Official Version | Community Version |
|--------|------------------|-------------------|
| **commit-commands** | Basic git helpers | `/commit`, `/commit-push-pr`, `/clean_gone` automation |
| **pr-review-toolkit** | Basic review tools | 6 specialized agents with detailed analysis |
| **security-guidance** | Basic best practices | 17 comprehensive security rules with proactive validation |

**Plus 6 additional plugins** only available in community marketplace:
- **agent-sdk-dev** - Claude Agent SDK development tools
- **feature-dev** - 7-phase structured feature development
- **plugin-developer-toolkit** - Create your own plugins
- **context-preservation** - Auto-save context before compaction
- **frontend-dev-guidelines** - React/TypeScript best practices
- **code-review** - Automated PR review with confidence scoring

**Recommendation**: Always use community plugins unless you have a specific reason to use official versions.

## Plugin Descriptions

### agent-sdk-dev
Streamlines Claude Agent SDK development:
- `/new-sdk-app` - Interactive project scaffolding
- `agent-sdk-verifier-py` - Validates Python SDK applications
- `agent-sdk-verifier-ts` - Validates TypeScript SDK applications

### commit-commands
Git workflow automation:
- `/commit` - Create commits with appropriate messages
- `/commit-push-pr` - Commit + push + create PR in one command
- `/clean_gone` - Remove stale branches marked [gone]

### code-review
Automated PR analysis:
- Multiple specialized agents
- Confidence-based scoring (≥80% threshold)
- Filters false positives
- Actionable review suggestions

### feature-dev
7-phase structured development:
- **Phase 1-2**: Requirements & exploration
- **Phase 3-4**: Architecture & planning
- **Phase 5-6**: Implementation & testing
- **Phase 7**: Documentation & deployment
- Uses: code-explorer, code-architect, code-reviewer agents

### security-guidance
Proactive security validation:
- 17 security rules via PreToolUse hooks
- XSS vulnerability detection
- Command injection prevention
- Unsafe pattern warnings
- Frontend & backend context-aware

### context-preservation
Auto-save critical context:
- Triggered before conversation compaction (PreCompact hook)
- Preserves: architecture decisions, debugging insights, design rationales
- Prevents loss of important context

### frontend-dev-guidelines
React/TypeScript best practices:
- Component design patterns
- Performance optimization
- Accessibility standards (WCAG)
- Testing strategies
- State management approaches

### pr-review-toolkit
6 specialized review agents:
- **comment-analyzer** - Analyzes PR comments and feedback
- **test-analyzer** - Reviews test coverage and quality
- **silent-failure-hunter** - Finds hidden bugs and edge cases
- **type-design-analyzer** - Evaluates TypeScript type design
- **code-reviewer** - General code quality review
- **code-simplifier** - Suggests simplifications

### plugin-developer-toolkit
Meta-plugin for plugin development:
- Interactive plugin creation
- 4 battle-tested templates: basic, with-skill, with-hooks, complete
- Comprehensive documentation
- Learning resources

## Verification

After container is built, verify installation:

```bash
# Check Claude Code status
claude /doctor

# List available marketplaces
claude /plugins marketplaces
# Should show: claude-code-plugins, community-plugins

# List installed plugins
claude /plugins list

# Test a plugin command (if commit-commands is installed)
claude /commit --help
```

## Troubleshooting

### Plugins not found

**Problem**: Claude can't find plugins from community marketplace

**Solution**:
```bash
# Check if marketplace is configured
cat ~/.claude/settings.json | jq .extraKnownMarketplaces

# Verify enabled plugins
cat ~/.claude/settings.json | jq .enabledPlugins

# Rebuild container if needed
```

### Feature installation fails

**Problem**: "Claude Code CLI not found"

**Solution**: Ensure `claude-code` feature is installed **before** this feature:
```json
{
  "features": {
    "ghcr.io/xrf9268-hue/features/claude-code:1": {},
    "ghcr.io/xrf9268-hue/features/claude-code-plugins:1": {}
  }
}
```

### Plugins conflict with official marketplace

**Problem**: Duplicate plugin names cause conflicts

**Solution**: Use different plugin sets or remove official plugins:
```json
{
  "ghcr.io/xrf9268-hue/features/claude-code:1": {
    "installPlugins": ""  // Disable official plugins
  },
  "ghcr.io/xrf9268-hue/features/claude-code-plugins:1": {
    "installPlugins": "essential"  // Use community plugins
  }
}
```

### Custom plugins not installing

**Problem**: `customPlugins` value is ignored

**Solution**: Ensure `installPlugins` is set to `"custom"`:
```json
{
  "installPlugins": "custom",
  "customPlugins": "commit-commands,feature-dev"
}
```

## Dependencies

- **Claude Code CLI**: Installed by `ghcr.io/xrf9268-hue/features/claude-code:1`
- **jq**: Included in most dev containers

## Compatibility

- ✅ Works with official Claude Code plugins (both marketplaces can coexist)
- ✅ Compatible with all Claude Code authentication methods
- ✅ Supports all plugin types: commands, agents, skills, hooks
- ✅ Works in any dev container with Claude Code installed

## Resources

- **Plugin Repository**: https://github.com/xrf9268-hue/claude-code-plugins
- **Claude Code Docs**: https://code.claude.com/docs
- **Universal DevContainer**: https://github.com/xrf9268-hue/universal-devcontainer

## Contributing

Found a bug or want to add a plugin? Visit:
- Plugins: https://github.com/xrf9268-hue/claude-code-plugins
- Feature: https://github.com/xrf9268-hue/universal-devcontainer

## License

MIT License - See repository for details
