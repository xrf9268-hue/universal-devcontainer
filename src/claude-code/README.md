# Claude Code Feature

A Dev Container Feature that installs and configures [Claude Code](https://code.claude.com) - the AI-powered coding assistant from Anthropic.

## Features

- 🤖 **Automated Installation** - Installs Claude Code CLI via npm
- 🔐 **Multiple Auth Methods** - Host credentials, API key, or manual login
- ⚙️ **Configurable Permissions** - Bypass or approval mode
- 🔌 **Plugin Support** - Pre-install Claude Code plugins
- 🛡️ **Sandbox Mode** - Optional command execution restrictions
- 📦 **Organization Support** - Force specific Claude organization

## Usage

Add to your `devcontainer.json`:

```json
{
  "features": {
    "ghcr.io/xrf9268-hue/features/claude-code:1": {}
  }
}
```

### With Custom Options

```json
{
  "features": {
    "ghcr.io/xrf9268-hue/features/claude-code:1": {
      "loginMethod": "host",
      "bypassPermissions": true,
      "enableSandbox": false
    },
    "ghcr.io/xrf9268-hue/features/claude-code-plugins:1": {
      "installPlugins": "essential"
    }
  }
}
```

## Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `loginMethod` | string | `host` | Authentication method: `host`, `api-key`, or `manual` |
| `bypassPermissions` | boolean | `true` | Auto-approve file operations (use with trusted repos only!) |
| `installPlugins` | string | `""` | Comma-separated plugin list from official marketplace. **Recommended: Use `claude-code-plugins` feature for enhanced community plugins** |
| `enableSandbox` | boolean | `false` | Enable command execution sandbox |
| `orgUUID` | string | `""` | Force specific Claude organization UUID |

### loginMethod

**`host` (Default, Recommended)**
- Copies Claude credentials from host machine (`~/.claude`)
- Requires mount configuration and import script
- Best for developers with existing Claude setup

**`api-key`**
- Uses `ANTHROPIC_API_KEY` environment variable
- Good for CI/CD or automated environments
- Requires API key from Anthropic Console

**`manual`**
- User runs `claude login` after container starts
- Interactive browser-based authentication
- Good for first-time setup or testing

### bypassPermissions

**`true` (Default)**
- ⚡ Fast workflow, no approval prompts
- 🚨 **Security Warning**: Claude can read/write files automatically
- ✅ Use ONLY with repositories you trust
- 🎯 Protected files (always denied): `.env`, `secrets/**`, SSH keys

**`false`**
- 🔐 Secure, requires approval for each file operation
- 📝 Better for unfamiliar or untrusted codebases
- ⏱️ Slower workflow due to approval prompts

### installPlugins

> **⚠️ DEPRECATION NOTICE**: Official marketplace plugins are basic versions.
> **Recommended**: Use the `claude-code-plugins` feature for enhanced community plugins with more features.

**Default**: Empty (no plugins installed)

**Official plugins** (basic versions, not recommended):
- `commit-commands` - Git commit helpers (limited features)
- `pr-review-toolkit` - Pull request review tools (basic)
- `security-guidance` - Security best practices (basic)

**Recommended alternative** - Use community plugins instead:
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

**To use official plugins explicitly** (not recommended):
```json
{
  "installPlugins": "commit-commands,pr-review-toolkit,security-guidance"
}
```

**No plugins** (default):
```json
{
  "installPlugins": ""
}
```

## Authentication Setup

### Method 1: Host Credentials (Recommended)

**Prerequisites**: Claude Code installed and authenticated on host

**devcontainer.json**:
```json
{
  "features": {
    "ghcr.io/xrf9268-hue/features/claude-code:1": {
      "loginMethod": "host"
    }
  },
  "mounts": [
    "source=${localEnv:HOME}/.claude,target=/host-claude,type=bind,readonly"
  ],
  "postCreateCommand": "bash ~/.claude/import-host-settings.sh"
}
```

**Host setup** (one-time):
```bash
npm install -g @anthropic-ai/claude-code
claude login
```

### Method 2: API Key

**Prerequisites**: API key from [Anthropic Console](https://console.anthropic.com)

**devcontainer.json**:
```json
{
  "features": {
    "ghcr.io/xrf9268-hue/features/claude-code:1": {
      "loginMethod": "api-key"
    }
  },
  "remoteEnv": {
    "ANTHROPIC_API_KEY": "${localEnv:ANTHROPIC_API_KEY}"
  }
}
```

**Set on host**:
```bash
export ANTHROPIC_API_KEY="sk-ant-..."
```

Or in VS Code settings:
```json
{
  "dev.containers.defaultEnv": {
    "ANTHROPIC_API_KEY": "sk-ant-..."
  }
}
```

### Method 3: Manual Login

**devcontainer.json**:
```json
{
  "features": {
    "ghcr.io/xrf9268-hue/features/claude-code:1": {
      "loginMethod": "manual"
    }
  }
}
```

**After container starts**:
```bash
claude login
```

## Examples

### Minimal Setup (Host Auth)

```json
{
  "name": "My Project",
  "image": "mcr.microsoft.com/devcontainers/base:ubuntu",
  "features": {
    "ghcr.io/xrf9268-hue/features/claude-code:1": {}
  },
  "mounts": [
    "source=${localEnv:HOME}/.claude,target=/host-claude,type=bind,readonly"
  ],
  "postCreateCommand": "bash ~/.claude/import-host-settings.sh"
}
```

### Secure Mode (Approval Required)

```json
{
  "features": {
    "ghcr.io/xrf9268-hue/features/claude-code:1": {
      "bypassPermissions": false,
      "enableSandbox": true
    }
  },
  "mounts": [
    "source=${localEnv:HOME}/.claude,target=/host-claude,type=bind,readonly"
  ],
  "postCreateCommand": "bash ~/.claude/import-host-settings.sh"
}
```

### API Key with Community Plugins

```json
{
  "features": {
    "ghcr.io/xrf9268-hue/features/claude-code:1": {
      "loginMethod": "api-key"
    },
    "ghcr.io/xrf9268-hue/features/claude-code-plugins:1": {
      "installPlugins": "custom",
      "customPlugins": "commit-commands,feature-dev,security-guidance"
    }
  },
  "remoteEnv": {
    "ANTHROPIC_API_KEY": "${localEnv:ANTHROPIC_API_KEY}"
  }
}
```

### Enterprise (Organization Lock + Sandbox)

```json
{
  "features": {
    "ghcr.io/xrf9268-hue/features/claude-code:1": {
      "loginMethod": "api-key",
      "bypassPermissions": false,
      "enableSandbox": true,
      "orgUUID": "org_abc123..."
    }
  },
  "remoteEnv": {
    "ANTHROPIC_API_KEY": "${localEnv:ANTHROPIC_API_KEY}"
  }
}
```

## Verification

After container starts:

```bash
# Check installation
claude --version

# View configuration
cat ~/.claude/settings.json

# Test Claude
claude "Hello, can you help me code?"
```

## File Structure

After installation, your container will have:

```
~/.claude/
├── settings.json              # Main configuration
├── bin/
│   ├── apikey.sh             # API key helper (if using api-key method)
│   └── import-host-settings.sh  # Host import script (if using host method)
├── commands/
│   └── review-pr.md          # Example slash command
├── skills/
│   └── reviewing-prs/
│       └── SKILL.md          # Example skill
└── CLAUDE.md                 # Global notes
```

## Security Considerations

### Protected Files (Always Denied)

Even with `bypassPermissions: true`, Claude cannot access:
- `.env`, `.env.*` files
- `secrets/**` directory
- SSH private keys (`id_rsa`, `id_ed25519`)

### Bypass Mode Warning

**Only use `bypassPermissions: true` with:**
- ✅ Your own code
- ✅ Trusted team repositories
- ✅ Isolated development environments

**Never use with:**
- ❌ Unfamiliar codebases
- ❌ Public repositories you don't trust
- ❌ Production environments

### Sandbox Mode

Enable `enableSandbox: true` for additional security:
- Restricts command execution
- Requires explicit approval for dangerous operations
- Recommended for untrusted repositories

## Troubleshooting

### "Claude not authenticated"

**For host method:**
- Verify `~/.claude/settings.json` exists on host
- Check mount is configured
- Run import script: `bash ~/.claude/import-host-settings.sh`

**For api-key method:**
- Verify `ANTHROPIC_API_KEY` is set: `echo $ANTHROPIC_API_KEY`
- Check API key is valid in Anthropic Console

**For manual method:**
- Run `claude login` and follow browser prompts

### "Permission denied"

- Check `bypassPermissions` setting in `~/.claude/settings.json`
- Verify file is not in protected list

### Plugins not installed

- Check `installPlugins` option value
- View enabled plugins: `cat ~/.claude/settings.json | jq .enabledPlugins`
- Manually enable: Edit `~/.claude/settings.json`

## Links

- **Claude Code Documentation**: https://code.claude.com/docs
- **Anthropic Console**: https://console.anthropic.com
- **Feature Repository**: https://github.com/xrf9268-hue/universal-devcontainer
- **Report Issues**: https://github.com/xrf9268-hue/universal-devcontainer/issues

## License

See [LICENSE](https://github.com/xrf9268-hue/universal-devcontainer/blob/main/LICENSE)
