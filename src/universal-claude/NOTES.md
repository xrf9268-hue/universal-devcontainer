# Universal Dev Container with Claude Code

Thank you for using the Universal Dev Container template! This template provides a production-ready development environment with Claude Code AI assistant, network security, and proxy support.

## 🚀 Quick Start

### Prerequisites

1. **Set PROJECT_PATH environment variable** (required):

   Add to your VS Code settings (`.vscode/settings.json` or User Settings):
   ```json
   {
     "dev.containers.defaultEnv": {
       "PROJECT_PATH": "/path/to/your/project"
     }
   }
   ```

   Or use the provided helper script:
   ```bash
   bash scripts/open-project.sh /path/to/your/project
   ```

2. **Claude Code Authentication**:
   - **host** method (default, recommended): Ensure you have `~/.claude/settings.json` on your host machine
   - **api-key** method: Set `ANTHROPIC_API_KEY` environment variable
   - **manual** method: Login manually after container starts using `claude login`

### Template Options You Selected

The template will configure your environment based on the options you chose during setup:

- **Claude Login Method**: `${claudeLoginMethod}` - How Claude Code authenticates
- **Firewall**: `${enableFirewall}` - Whitelist-based network security
- **Strict Proxy Mode**: `${strictProxyMode}` - Force all traffic through proxy
- **Timezone**: `${timezone}` - Container timezone setting
- **Sandbox Mode**: `${enableSandbox}` - Claude Code command restrictions
- **Bypass Permissions**: `${bypassPermissions}` - Auto-approve Claude operations

## 🔐 Security

### Firewall Configuration

**If Firewall is Enabled (`enableFirewall: true`):**

The container includes a whitelist-based outbound firewall that blocks all egress traffic except:

**Default Whitelisted Domains:**
- `registry.npmjs.org`, `npmjs.org` - npm packages
- `github.com`, `api.github.com`, `objects.githubusercontent.com` - GitHub
- `claude.ai`, `api.anthropic.com`, `console.anthropic.com` - Claude Code

**Add Custom Domains:**
```json
{
  "remoteEnv": {
    "EXTRA_ALLOW_DOMAINS": "example.com another.com"
  }
}
```

**Strict Proxy Mode:**
If you selected `strictProxyMode: true`, ALL outbound traffic must go through your HTTP_PROXY. Direct HTTPS to whitelisted domains is blocked.

### Claude Code Permissions

**Bypass Mode (`bypassPermissions: true` - DEFAULT):**
- ✅ Fast, no approval prompts
- ⚠️ Claude can read/write files automatically
- 🎯 Use ONLY with trusted repositories

**Approval Mode (`bypassPermissions: false`):**
- ✅ You approve every file operation
- ✅ More secure for unfamiliar codebases
- ⚠️ Slower workflow

**Protected Files (Always Denied):**
Even in bypass mode, Claude cannot access:
- `.env`, `.env.*` files
- `secrets/**` directory
- SSH private keys (`id_rsa`, `id_ed25519`)

## 🌐 Proxy Configuration

If you're behind a corporate proxy:

1. **Set proxy environment variables** on your host:
   ```bash
   export HOST_PROXY_URL="http://proxy.company.com:8080"
   export NO_PROXY="localhost,127.0.0.1,.local"
   ```

2. **Configure in VS Code settings**:
   ```json
   {
     "dev.containers.defaultEnv": {
       "HOST_PROXY_URL": "http://proxy.company.com:8080",
       "NO_PROXY": "localhost,127.0.0.1,.local"
     }
   }
   ```

3. **Strict proxy mode** ensures all traffic routes through the proxy.

## 📁 Directory Structure

```
/workspace        → Your project (from PROJECT_PATH)
/universal        → Dev container configuration
/commandhistory   → Persistent shell history (volume)
/host-claude      → Host Claude settings (read-only, if using 'host' method)
```

## 🛠 Common Tasks

### Using Claude Code

```bash
# If you selected 'manual' login method, authenticate first:
claude login

# Chat with Claude
claude

# Ask Claude to perform tasks
claude "refactor this function to be more efficient"
```

### Checking Firewall Status

```bash
# View current iptables rules (if firewall enabled)
sudo iptables -L OUTPUT -n -v

# Test connectivity
curl -v https://github.com
curl -v https://example.com  # Should fail if not whitelisted
```

### Updating Configuration

To change settings after container is created:

1. **Rebuild container**: Cmd/Ctrl + Shift + P → "Dev Containers: Rebuild Container"
2. **Or modify `.devcontainer/devcontainer.json`** and rebuild

## 📖 Documentation

- **Full Documentation**: https://github.com/xrf9268-hue/universal-devcontainer
- **Troubleshooting**: See `README.md` and `docs/TROUBLESHOOTING.en.md`
- **Security Policy**: See `docs/SECURITY.md`
- **Claude Code Docs**: https://code.claude.com/docs

## ⚠️ Important Notes

1. **PROJECT_PATH is required** - The container will not start without it
2. **Firewall requires NET_ADMIN** - Already configured in template
3. **Bypass mode security** - Only use with code you trust
4. **Proxy environment** - Set HOST_PROXY_URL before starting container
5. **Host .claude mount** - Only works with 'host' login method

## 🐛 Troubleshooting

**Container fails to start:**
- Check PROJECT_PATH is set and points to a valid directory
- Ensure the directory is shared with Docker (macOS: Docker Desktop → Settings → Resources → File Sharing)

**Claude Code not authenticated:**
- Check your login method selection
- For 'host' method: Verify `~/.claude/settings.json` exists on host
- For 'api-key' method: Set `ANTHROPIC_API_KEY` environment variable
- For 'manual' method: Run `claude login` after container starts

**Network issues:**
- Check firewall configuration if enabled
- Add required domains to EXTRA_ALLOW_DOMAINS
- Verify proxy settings if behind corporate firewall

**Permission denied errors:**
- If firewall enabled, ensure NET_ADMIN capability is set (already in template)
- Check file permissions in mounted PROJECT_PATH

## 💡 Tips

- Use **bypass mode** for personal projects, **approval mode** for unknown code
- Enable **sandbox mode** for additional security when testing unfamiliar repos
- Use **strict proxy mode** in corporate environments with mandatory proxy
- Set your **local timezone** for accurate timestamps
- Add frequently used domains to whitelist instead of disabling firewall

---

**Need help?** Open an issue at https://github.com/xrf9268-hue/universal-devcontainer/issues
