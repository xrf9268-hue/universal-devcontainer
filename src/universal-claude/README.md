# Universal Dev Container with Claude Code

A production-ready Dev Container template featuring Claude Code AI assistant, network firewall, and enterprise proxy support.

## Features

- 🤖 **Claude Code Integration** - AI-powered coding assistant
- 🔒 **Network Firewall** - Whitelist-based outbound traffic control
- 🌐 **Proxy Support** - Corporate proxy and strict mode
- 🛠️ **Pre-configured Tools** - Node.js, Python, GitHub CLI
- 📦 **Persistent History** - Command history across container rebuilds
- ⚙️ **Flexible Authentication** - Multiple Claude login methods

## Quick Start

### Option 1: Use in VS Code

1. Open Command Palette (Cmd/Ctrl + Shift + P)
2. Select "Dev Containers: Add Dev Container Configuration Files..."
3. Choose "Universal Dev Container with Claude Code"
4. Configure options when prompted
5. Reopen in container

### Option 2: Manual Installation

1. Create `.devcontainer/devcontainer.json`:
   ```json
   {
     "name": "My Project",
     "image": "ghcr.io/xrf9268-hue/universal-claude:latest"
   }
   ```

2. Add environment variables:
   ```json
   {
     "dev.containers.defaultEnv": {
       "PROJECT_PATH": "${localWorkspaceFolder}"
     }
   }
   ```

3. Reopen in container

## Template Options

### Claude Login Method
- **host** (recommended): Copies from `~/.claude` on host machine
- **api-key**: Uses `ANTHROPIC_API_KEY` environment variable
- **manual**: Requires manual `claude login` after container starts

### Firewall
- **true** (default): Enables whitelist-based outbound firewall
- **false**: No firewall restrictions

### Strict Proxy Mode
- **true**: Forces ALL traffic through HTTP_PROXY (no direct HTTPS)
- **false** (default): Allows direct HTTPS to whitelisted domains

### Timezone
Choose your container timezone (default: UTC):
- America/New_York, America/Los_Angeles, America/Chicago
- Europe/London, Europe/Paris
- Asia/Tokyo, Asia/Shanghai, Asia/Singapore
- Australia/Sydney

### Sandbox Mode
- **true**: Restricts Claude Code command execution
- **false** (default): Full command access

### Bypass Permissions
- **true** (default): Auto-approve Claude operations (use with trusted repos only!)
- **false**: Require approval for each file operation

## Prerequisites

### Required
- **PROJECT_PATH**: Must be set via environment variable or helper script
- **Docker Desktop**: File sharing enabled for project directory
- **VS Code**: Dev Containers extension

### Optional
- **Claude Authentication**:
  - For 'host' method: `~/.claude/settings.json` on host
  - For 'api-key' method: `ANTHROPIC_API_KEY` environment variable

## Configuration

### Environment Variables

Set in VS Code settings or `.devcontainer/devcontainer.json`:

```json
{
  "dev.containers.defaultEnv": {
    "PROJECT_PATH": "/path/to/project",
    "HOST_PROXY_URL": "http://proxy:8080",
    "NO_PROXY": "localhost,127.0.0.1",
    "ANTHROPIC_API_KEY": "sk-ant-...",
    "CLAUDE_ORG_UUID": "org_...",
    "EXTRA_ALLOW_DOMAINS": "example.com another.com"
  }
}
```

### Firewall Whitelist

Default whitelisted domains:
- `registry.npmjs.org`, `npmjs.org`
- `github.com`, `api.github.com`
- `claude.ai`, `api.anthropic.com`

Add custom domains via `EXTRA_ALLOW_DOMAINS`.

## Security

### Claude Code Permissions

**Bypass Mode (Default):**
- ⚡ Fast workflow, no prompts
- ⚠️ Use ONLY with trusted repositories

**Approval Mode:**
- 🔐 Secure, requires approval for operations
- 📝 Better for unfamiliar codebases

### Always Protected Files
Even in bypass mode:
- `.env`, `.env.*`
- `secrets/**`
- SSH keys (`id_rsa`, `id_ed25519`)

### Network Security

Firewall blocks all outbound traffic except:
1. Localhost and established connections
2. DNS queries
3. Proxy (if configured)
4. Whitelisted domains (HTTPS:443, SSH:22)

## Troubleshooting

### Container won't start
- Verify `PROJECT_PATH` is set and valid
- Check Docker file sharing settings (macOS)

### Claude not authenticated
- **host method**: Check `~/.claude/settings.json` exists
- **api-key method**: Verify `ANTHROPIC_API_KEY` is set
- **manual method**: Run `claude login` after start

### Network blocked
- Add required domains to `EXTRA_ALLOW_DOMAINS`
- Check proxy configuration
- Disable firewall if not needed (`enableFirewall: false`)

## Examples

### Basic Setup
```json
{
  "name": "My App",
  "extends": "ghcr.io/xrf9268-hue/devcontainer-templates/universal-claude"
}
```

### With Custom Options
```json
{
  "name": "Enterprise App",
  "extends": "ghcr.io/xrf9268-hue/devcontainer-templates/universal-claude",
  "overrideFeatureInstallOrder": [
    "universal-claude"
  ],
  "remoteEnv": {
    "PROJECT_PATH": "${localWorkspaceFolder}",
    "HOST_PROXY_URL": "${localEnv:HTTP_PROXY}",
    "STRICT_PROXY_ONLY": "true",
    "BYPASS_PERMISSIONS": "false"
  }
}
```

## Links

- **Documentation**: https://github.com/xrf9268-hue/universal-devcontainer
- **Issues**: https://github.com/xrf9268-hue/universal-devcontainer/issues
- **Claude Code**: https://code.claude.com/docs
- **Dev Containers**: https://containers.dev

## License

See [LICENSE](https://github.com/xrf9268-hue/universal-devcontainer/blob/main/LICENSE)
