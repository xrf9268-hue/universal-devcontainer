# Firewall Feature

A Dev Container Feature that configures an iptables-based egress firewall with domain whitelisting and proxy support.

## Features

- 🔒 **Default Deny** - Blocks all outbound traffic except whitelisted destinations
- 📋 **Preset Configurations** - Standard, strict, or permissive modes
- 🌐 **Proxy Support** - Automatic proxy detection and allowlisting
- 🎯 **Custom Whitelists** - Add your own domains
- 🔑 **SSH Control** - GitHub-only, all, or none
- ⚡ **Auto-activation** - Applies on container start

## Usage

Add to your `devcontainer.json`:

```json
{
  "features": {
    "ghcr.io/xrf9268-hue/features/firewall:1": {}
  }
}
```

### With Custom Options

```json
{
  "features": {
    "ghcr.io/xrf9268-hue/features/firewall:1": {
      "preset": "standard",
      "whitelistDomains": "example.com,api.myservice.com",
      "strictProxyMode": false,
      "allowSSH": "github-only"
    }
  }
}
```

## Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `preset` | string | `standard` | Firewall preset: `standard`, `strict`, or `permissive` |
| `whitelistDomains` | string | `""` | Additional comma-separated domains to whitelist |
| `strictProxyMode` | boolean | `false` | Force all traffic through HTTP_PROXY (no direct HTTPS) |
| `allowSSH` | string | `github-only` | SSH access: `github-only`, `all`, or `none` |

### Preset Configurations

**`standard` (Default)**

Balanced security for typical development workflows.

**Whitelisted domains**:
- npm: `registry.npmjs.org`, `npmjs.org`
- GitHub: `github.com`, `api.github.com`, `*.githubusercontent.com`
- Claude: `claude.ai`, `api.anthropic.com`, `console.anthropic.com`
- Python: `pypi.org`, `files.pythonhosted.org`

**`strict`**

Minimal access for high-security environments.

**Whitelisted domains**:
- `registry.npmjs.org` (npm packages only)
- `github.com` (Git operations only)
- `api.anthropic.com` (Claude API only)

**`permissive`**

Relaxed rules for complex development needs.

**Includes `standard` domains plus**:
- Docker registries: `docker.io`, `gcr.io`, `quay.io`, `hub.docker.com`
- Go modules: `golang.org`, `proxy.golang.org`
- Cloud storage: `storage.googleapis.com`

### strictProxyMode

**`false` (Default)**

- Direct HTTPS allowed to whitelisted domains
- Proxy used for other traffic (if configured)
- Best for most development scenarios

**`true`**

- ALL traffic must go through HTTP_PROXY
- Direct HTTPS blocked even to whitelisted domains
- Required for corporate environments with mandatory proxies
- Requires `HTTP_PROXY` environment variable

### allowSSH

**`github-only` (Default)**

- SSH allowed only to github.com:22
- Good for Git operations while blocking other SSH

**`all`**

- SSH allowed to any destination
- Use when connecting to multiple Git hosts or SSH servers

**`none`**

- All SSH blocked
- Use HTTPS for Git operations instead

## Examples

### Standard Development Setup

```json
{
  "name": "My App",
  "image": "mcr.microsoft.com/devcontainers/base:ubuntu",
  "features": {
    "ghcr.io/xrf9268-hue/features/firewall:1": {}
  }
}
```

### With Custom API Domains

```json
{
  "features": {
    "ghcr.io/xrf9268-hue/features/firewall:1": {
      "whitelistDomains": "api.stripe.com,api.twilio.com,api.sendgrid.com"
    }
  }
}
```

### Corporate Environment (Strict Proxy)

```json
{
  "features": {
    "ghcr.io/xrf9268-hue/features/firewall:1": {
      "preset": "strict",
      "strictProxyMode": true,
      "allowSSH": "none"
    }
  },
  "remoteEnv": {
    "HTTP_PROXY": "${localEnv:HTTP_PROXY}",
    "HTTPS_PROXY": "${localEnv:HTTPS_PROXY}",
    "NO_PROXY": "localhost,127.0.0.1"
  }
}
```

### Permissive for Microservices

```json
{
  "features": {
    "ghcr.io/xrf9268-hue/features/firewall:1": {
      "preset": "permissive",
      "whitelistDomains": "consul.service,vault.service,kafka.local",
      "allowSSH": "all"
    }
  }
}
```

### High Security Mode

```json
{
  "features": {
    "ghcr.io/xrf9268-hue/features/firewall:1": {
      "preset": "strict",
      "strictProxyMode": true,
      "allowSSH": "none",
      "whitelistDomains": ""
    }
  }
}
```

## How It Works

### Firewall Rules

1. **Allow** - Localhost (127.0.0.1)
2. **Allow** - Established/related connections
3. **Allow** - DNS queries (UDP/TCP port 53)
4. **Allow** - HTTP proxy (if configured)
5. **Allow** - HTTPS (port 443) to whitelisted domains (unless strictProxyMode)
6. **Allow** - SSH (port 22) based on allowSSH setting
7. **DROP** - Everything else (default policy)

### Proxy Detection

The firewall automatically detects and allows connections to your proxy from these environment variables (in order):
1. `HTTP_PROXY`
2. `HTTPS_PROXY`
3. `ALL_PROXY`

### DNS Resolution

- Domain whitelists are resolved to IPv4 addresses during firewall initialization
- IP addresses are added to iptables rules
- Resolution happens at container start, so changes require container restart

## Management

### View Current Rules

```bash
sudo iptables -L OUTPUT -n -v
```

### Test Connectivity

```bash
# Should succeed (whitelisted)
curl -v https://github.com
curl -v https://npmjs.org

# Should fail (not whitelisted)
curl -v https://example.com
```

### Manually Apply Rules

```bash
sudo bash /usr/local/bin/init-firewall.sh
```

### Add Runtime Whitelist

Edit `/usr/local/bin/init-firewall.sh`:

```bash
ALLOW_DOMAINS=(
  # Existing domains...
  "newdomain.com"  # Add here
)
```

Then reapply:
```bash
sudo bash /usr/local/bin/init-firewall.sh
```

### Disable Firewall

Remove the feature from `devcontainer.json` and rebuild container.

**Temporary disable** (persists until container restart):
```bash
sudo iptables -P OUTPUT ACCEPT
sudo iptables -F OUTPUT
```

## Security Considerations

### What It Protects

✅ **Blocks**:
- Data exfiltration to unknown domains
- Accidental connections to malicious sites
- Unnecessary outbound traffic

✅ **Allows**:
- Essential development tools (npm, pip, git)
- Configured APIs and services
- Proxy-routed traffic

### What It Doesn't Protect

❌ **Does NOT block**:
- Localhost connections (127.0.0.1)
- Established connections (responses to your requests)
- Traffic within container's internal network

❌ **Does NOT protect**:
- Against malicious code running in container
- Against compromised whitelisted domains
- Against DNS spoofing (without DNSSEC)

### Best Practices

1. **Use `strict` preset** for unfamiliar codebases
2. **Enable `strictProxyMode`** in corporate environments
3. **Minimize `whitelistDomains`** - only add what you need
4. **Combine with other security**:
   - Claude Code permission controls
   - Read-only mounts for sensitive files
   - Principle of least privilege

### Limitations

- Firewall rules are ephemeral (reset on container recreate)
- Requires `NET_ADMIN` capability (already configured)
- IPv4 only (IPv6 not currently supported)
- DNS resolved at startup (not dynamic)

## Troubleshooting

### "iptables not found"

Feature installs iptables automatically. If you see this error:
- Rebuild container to ensure feature ran
- Check install logs during container creation

### "No permission to manage iptables"

- Verify `NET_ADMIN` capability (feature sets this automatically)
- Check Docker/container runtime allows capabilities
- May not work in some cloud environments (e.g., GitHub Codespaces)

### Connection refused to allowed domain

1. **Check domain is whitelisted**:
   ```bash
   cat /usr/local/bin/init-firewall.sh | grep ALLOW_DOMAINS
   ```

2. **Verify DNS resolution**:
   ```bash
   getent ahostsv4 github.com
   ```

3. **Check iptables rules**:
   ```bash
   sudo iptables -L OUTPUT -n -v
   ```

4. **Reapply firewall**:
   ```bash
   sudo bash /usr/local/bin/init-firewall.sh
   ```

### Proxy connections failing

1. **Verify proxy environment variables**:
   ```bash
   echo $HTTP_PROXY
   echo $HTTPS_PROXY
   ```

2. **Check proxy is allowed in firewall**:
   ```bash
   sudo iptables -L OUTPUT -n | grep <proxy-ip>
   ```

3. **Enable strictProxyMode** if corporate proxy is mandatory

### Need to allow more domains

Add to `whitelistDomains` option:
```json
{
  "whitelistDomains": "example.com,another.com"
}
```

Or edit runtime script and reapply (see Management section)

## Performance Impact

- ⚡ **Negligible** - iptables operates at kernel level
- 🚀 **No latency** - Rules evaluated in nanoseconds
- 💾 **Low memory** - Rules consume ~1KB per domain
- 📊 **Startup delay** - ~1-2 seconds for DNS resolution (100+ domains)

## Compatibility

| Environment | Support |
|-------------|---------|
| VS Code Dev Containers | ✅ Full support |
| GitHub Codespaces | ⚠️ Limited (requires capabilities) |
| Docker Desktop | ✅ Full support |
| Podman | ⚠️ Untested |
| Remote Containers | ✅ Full support |

## Links

- **iptables Tutorial**: https://www.netfilter.org/documentation/
- **Feature Repository**: https://github.com/xrf9268-hue/universal-devcontainer
- **Security Documentation**: https://github.com/xrf9268-hue/universal-devcontainer/blob/main/docs/SECURITY.md
- **Report Issues**: https://github.com/xrf9268-hue/universal-devcontainer/issues

## License

See [LICENSE](https://github.com/xrf9268-hue/universal-devcontainer/blob/main/LICENSE)
