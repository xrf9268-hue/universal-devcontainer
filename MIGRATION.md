# Migration Guide: Removing Pre-installed Official Plugins

## Version 2.2.0 Breaking Change

**TL;DR**: Pre-installed official plugins are removed. Use `claude-code-plugins` feature instead for better plugins.

### What Changed?

**Before (v2.1.0 and earlier)**:
```json
{
  "ghcr.io/xrf9268-hue/features/claude-code:1": {
    // Automatically installs: commit-commands, pr-review-toolkit, security-guidance
  }
}
```

**After (v2.2.0+)**:
```json
{
  "ghcr.io/xrf9268-hue/features/claude-code:1": {
    // No plugins installed by default
  },
  "ghcr.io/xrf9268-hue/features/claude-code-plugins:1": {
    "installPlugins": "essential"  // Better versions + more plugins
  }
}
```

### Why This Change?

1. **Better Plugins**: Community plugins have more features
2. **No Redundancy**: Eliminates duplicate plugins
3. **User Choice**: Explicit control over what's installed
4. **Best Practice**: Aligns with existing examples

### Migration Steps

#### Option 1: Switch to Community Plugins (Recommended)

Add the `claude-code-plugins` feature:

```json
{
  "features": {
    "ghcr.io/xrf9268-hue/features/claude-code:1": {
      "loginMethod": "host",
      "bypassPermissions": true
    },
    "ghcr.io/xrf9268-hue/features/claude-code-plugins:1": {
      "installPlugins": "essential"
    }
  }
}
```

**Benefits**:
- ✅ Enhanced versions of the same 3 plugins
- ✅ Plus 1 additional plugin (context-preservation)
- ✅ Access to 5 more specialized plugins
- ✅ Better maintained and more features

#### Option 2: Keep Official Plugins (Not Recommended)

Explicitly specify official plugins:

```json
{
  "ghcr.io/xrf9268-hue/features/claude-code:1": {
    "installPlugins": "commit-commands,pr-review-toolkit,security-guidance"
  }
}
```

**Drawbacks**:
- ⚠️ Limited features compared to community versions
- ⚠️ No access to additional specialized plugins

#### Option 3: No Plugins

Keep the new default (no plugins):

```json
{
  "ghcr.io/xrf9268-hue/features/claude-code:1": {
    "loginMethod": "host"
    // No plugins
  }
}
```

### Comparison Table

| Feature | Official Plugins | Community Plugins (essential) |
|---------|-----------------|-------------------------------|
| commit-commands | Basic | Enhanced with 3 commands |
| pr-review-toolkit | Basic | 6 specialized agents |
| security-guidance | Basic | 17 security rules |
| context-preservation | ❌ Not available | ✅ Included |
| Additional plugins | ❌ None | ✅ 5 more available |
| Active development | ⚠️ Slower | ✅ Active |

### Who Is Affected?

**Not Affected** (no action needed):
- ✅ Already using `claude-code-plugins` feature
- ✅ Already set `installPlugins` explicitly
- ✅ Using `with-advanced-plugins` example

**Affected** (action required):
- ⚠️ Relying on default plugin installation
- ⚠️ Not using `claude-code-plugins` feature

### Testing Your Migration

After updating your `devcontainer.json`:

1. Rebuild container
2. Verify plugins:
   ```bash
   claude /plugins list
   ```
3. Check marketplace:
   ```bash
   claude /plugins marketplaces
   # Should show: community-plugins
   ```

### Plugin Feature Comparison

#### commit-commands

**Official Version**:
- Basic git commit helpers

**Community Version**:
- `/commit` - Create commits with AI-generated messages
- `/commit-push-pr` - Commit + push + create PR in one command
- `/clean_gone` - Remove stale branches marked [gone]

#### pr-review-toolkit

**Official Version**:
- Basic PR review tools

**Community Version**:
- 6 specialized agents:
  - comment-analyzer - Analyzes PR comments and feedback
  - test-analyzer - Reviews test coverage and quality
  - silent-failure-hunter - Finds hidden bugs and edge cases
  - type-design-analyzer - Evaluates TypeScript type design
  - code-reviewer - General code quality review
  - code-simplifier - Suggests simplifications

#### security-guidance

**Official Version**:
- Basic security best practices

**Community Version**:
- 17 comprehensive security rules
- Proactive validation via PreToolUse hooks
- XSS vulnerability detection
- Command injection prevention
- Unsafe pattern warnings
- Frontend & backend context-aware

### Additional Community Plugins

Beyond the three plugins that have official equivalents, you get access to:

1. **agent-sdk-dev** - Claude Agent SDK development tools
2. **feature-dev** - 7-phase structured feature development
3. **plugin-developer-toolkit** - Create your own plugins
4. **context-preservation** - Auto-save context before compaction
5. **frontend-dev-guidelines** - React/TypeScript best practices
6. **code-review** - Automated PR review with confidence scoring

### Need Help?

- Check examples: `examples/with-advanced-plugins/`
- Read docs: `src/features/claude-code-plugins/README.md`
- Open issue: https://github.com/xrf9268-hue/universal-devcontainer/issues

## Frequently Asked Questions

### Q: Why were the official plugins removed as default?

A: The community plugins are superior versions with significantly more features. Installing both creates redundancy and confusion. Making community plugins the standard provides a better experience for all users.

### Q: Can I still use official plugins?

A: Yes, you can explicitly set `installPlugins: "commit-commands,pr-review-toolkit,security-guidance"` in the `claude-code` feature. However, this is not recommended as community plugins offer more functionality.

### Q: Will this break my existing setup?

A: Only if you were relying on the default plugin installation without explicitly configuring it. If you had `installPlugins` explicitly set or were already using `claude-code-plugins`, no changes are needed.

### Q: Can I use both official and community plugins?

A: Yes, but it's not recommended as it creates duplicate functionality. The plugins are distinguished by `@marketplace-name` suffix, so technically they can coexist, but this adds unnecessary complexity.

### Q: What if I don't want any plugins?

A: The new default is no plugins, which is perfect for you! Just don't add the `claude-code-plugins` feature.

### Q: How do I report issues with community plugins?

A: Report issues at https://github.com/xrf9268-hue/claude-code-plugins/issues

## Version History

- **v2.1.0 and earlier**: Official plugins (commit-commands, pr-review-toolkit, security-guidance) installed by default
- **v2.2.0**: Default changed to no plugins; community plugins recommended
