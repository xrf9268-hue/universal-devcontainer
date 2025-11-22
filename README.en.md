# Universal Dev Container — Claude Code Development Environment

> Reusable Dev Container configuration with integrated Claude Code, firewall, and proxy support.
> **bypassPermissions** enabled by default — for **trusted repositories** and **isolated environments** only.

**Languages**: [English](README.en.md) | [中文](README.md)

---

## What is This?

A pre-configured development container environment featuring:

- ✅ **Claude Code** — AI programming assistant (pre-configured with login and permissions)
- ✅ **Development Tools** — Node.js (LTS), Python 3.12, GitHub CLI
- ✅ **Network Security** — Whitelist-based egress firewall
- ✅ **Proxy Support** — VPN/Corporate proxy passthrough
- ✅ **Reusable** — One configuration for all your projects

---

## Prerequisites

- VS Code ≥ 1.105 + Dev Containers extension ≥ 0.427
- Docker Desktop running
- (Optional) `npm i -g @devcontainers/cli` — For script assistance

**Restricted Network/Proxy Environment**: Read [Proxy Setup Guide](docs/PROXY_SETUP.md) first

---

## Quick Start 🚀

**Core Concept**: This repository provides a reusable Dev Container configuration that dynamically mounts your project via `workspaceMount` and directly reuses the host machine's Claude login state.

### Method 1: Using Script (Easiest) ⭐

```bash
# 1. Install and login to Claude Code on host (one-time only)
npm i -g @anthropic-ai/claude-code
claude login

# 2. Open container for any project
/path/to/universal-devcontainer/scripts/open-project.sh /path/to/your/project

# Or in current directory
cd /path/to/your/project
/path/to/universal-devcontainer/scripts/open-project.sh .

# Or clone from Git repository and develop directly
/path/to/universal-devcontainer/scripts/open-project.sh https://github.com/owner/repo.git
```

**How it Works**:
1. Script sets `PROJECT_PATH` environment variable to your project
2. Opens the universal-devcontainer directory (not your project directory)
3. VS Code prompts "Reopen in Container"
4. After container starts, your project is mounted at `/workspace`

---

### Method 2: Manual Environment Variable Setup

If you prefer not using the script:

```bash
# 1. Set project path (required)
export PROJECT_PATH=/path/to/your/project

# 2. Ensure Claude Code is installed and logged in on host (one-time)
npm i -g @anthropic-ai/claude-code
claude login

# 3. Open universal-devcontainer directory with VS Code
code /path/to/universal-devcontainer

# 4. In VS Code: Dev Containers: Reopen in Container
```

---

### Method 3: Developing the Container Itself

If you want to develop universal-devcontainer itself in the container, also provide `PROJECT_PATH` (or use script):

```bash
# Method 1: Using script (recommended)
/path/to/universal-devcontainer/scripts/open-project.sh /path/to/universal-devcontainer

# Method 2: Manual environment variable
export PROJECT_PATH=/path/to/universal-devcontainer
code /path/to/universal-devcontainer
# In VS Code: Dev Containers: Reopen in Container
```

**Note**: To ensure compatibility and predictable behavior, this configuration uses "Approach A", mounting only when `PROJECT_PATH` is set.

**Container Path Conventions**:
- Your external project: `/workspace`
- This repository (tools & scripts): `/universal`

---

## Verify Installation

After container starts, open terminal and verify:

```bash
# Verify automatic host login reuse
claude /doctor

# Check Claude Code
claude /help
/permissions          # Should show bypassPermissions

# Check development tools
node -v               # LTS version
python3 --version     # 3.12.x (Ubuntu 24.04)
gh --version          # GitHub CLI

# Check proxy (if configured)
env | grep -i proxy
nc -vz host.docker.internal 1082  # Test host proxy connectivity
```

---

## Environment Variable Configuration

### Login and Organization Configuration (Optional)

By default, as long as you've run `claude login` on the host, the container will copy login configuration from host `~/.claude/settings.json` to the container during initialization. Generally **no additional environment variables needed**.

To override login method or use pure API Key mode, set:

| Variable | Description | Example |
|----------|-------------|---------|
| `CLAUDE_LOGIN_METHOD` | Login method: `console`/`claudeai`/`apiKey` | `console` |
| `ANTHROPIC_API_KEY` | API Key (required for `apiKey` method) | `sk-ant-xxx...` |

Set on host (container will automatically read):

```bash
# Method 1: Environment variables
export CLAUDE_LOGIN_METHOD=console
export ANTHROPIC_API_KEY=sk-ant-...

# Method 2: VS Code settings.json
// ~/.config/Code/User/settings.json
{
  "dev.containers.defaultEnv": {
    "CLAUDE_LOGIN_METHOD": "console",
    "ANTHROPIC_API_KEY": "sk-ant-..."
  }
}
```

---

### Optional Variables

| Variable | Description | Default | Example |
|----------|-------------|---------|---------|
| `CLAUDE_ORG_UUID` | Force use of specific organization | - | `org-xxx...` |
| `HOST_PROXY_URL` | Host HTTP/HTTPS proxy | - | `http://host.docker.internal:7890` |
| `ALL_PROXY` | Host SOCKS proxy | - | `socks5h://host.docker.internal:1080` |
| `NO_PROXY` | Addresses to bypass proxy | - | `localhost,127.0.0.1,.local` |
| `EXTRA_ALLOW_DOMAINS` | Additional firewall whitelist | - | `"gitlab.com myapi.com"` |
| `ALLOW_SSH_ANY` | Allow SSH to any destination | `0` | `1` |
| `STRICT_PROXY_ONLY` | Proxy-only mode (strict) | `1` | `0` |
| `ENABLE_CLAUDE_SANDBOX` | Claude sandbox mode | - | `1` |

**Detailed Proxy Configuration**: See [docs/PROXY_SETUP.md](docs/PROXY_SETUP.md)

---

## ⚠️ Security and Credential Sharing

This configuration shares host login information via **read-only mount + one-time copy**:

1. **No Login Required in Container**: On first container creation, login configuration is read from host `~/.claude/settings.json` and copied to container's `/home/vscode/.claude/settings.json`.
2. **Session Expiry Handling**: If prompted for expired token, run `claude login` on host terminal, then in VS Code execute "Rebuild Without Cache" to recreate container and re-copy latest login state.
3. **No Write-back to Host**: The `bootstrap-claude.sh` script only writes to container's `/home/vscode/.claude/settings.json`, never modifies host `~/.claude`, reducing risk of accidental credential changes.

---

## Mode Switching

Default uses **bypass mode** (no manual confirmation). For a more secure mode, manually edit `~/.claude/settings.json`:

```jsonc
{
  "permissions": {
    // More secure: requires confirmation for edits
    "defaultMode": "acceptEdits",
    // Optional: completely disable bypass mode (stricter enterprise policy)
    "disableBypassPermissionsMode": "disable"
  }
}
```

---

## Firewall Whitelist

Container **denies all outbound connections** by default, only allowing HTTPS (443) to these domains:

**Base Whitelist**:
- `registry.npmjs.org` / `npmjs.org` — npm package management
- `github.com` / `api.github.com` / `objects.githubusercontent.com` — GitHub
- `claude.ai` / `api.anthropic.com` / `console.anthropic.com` — Claude Code
- DNS servers (UDP/TCP port 53)
- GitHub SSH (port 22, unless `ALLOW_SSH_ANY=1`)

**Extended Whitelist**:

```bash
export EXTRA_ALLOW_DOMAINS="gitlab.mycompany.com registry.internal.net"
```

Firewall will additionally allow these domains.

**Strict Proxy Mode** (`STRICT_PROXY_ONLY=1`):
- Only allows DNS and proxy port
- All internet access must go through proxy
- Suitable for restricted networks with high security requirements

---

## Built-in Features

### Pre-installed Plugins
- `commit-commands` — Commit assistance
- `pr-review-toolkit` — PR review
- `security-guidance` — Security guidance

**Plugin Troubleshooting**: If `/doctor` shows plugin "not found in marketplace":

```bash
# Re-run bootstrap script
bash .devcontainer/bootstrap-claude.sh

# Verify
claude /plugins marketplaces        # Should show claude-code-plugins
claude /plugins search commit-commands
```

---

### Custom Commands and Skills
- `/review-pr <PR-number>` — Analyze GitHub PR
- `reviewing-prs` skill — Code review AI skill

---

### Port Forwarding
Default forwarded ports: `3000`, `5173`, `8000`, `9003`, `1024`, `4444`

---

### Pre-installed Tools
- **Development Tools**: Node.js (LTS), Python 3.12, GitHub CLI
- **System Tools**: git, curl, jq, iptables, dnsutils, netcat

---

## Directory Structure

```
universal-devcontainer/
├── .devcontainer/
│   ├── devcontainer.json       # Main config (binds /workspace & /universal via mounts)
│   ├── Dockerfile              # Base image
│   ├── bootstrap-claude.sh     # Claude Code installation
│   ├── init-firewall.sh        # Firewall rules
│   └── setup-proxy.sh          # Proxy configuration
├── scripts/
│   ├── open-project.sh         # Mount external project to container (sets PROJECT_PATH)
│   ├── validate-all.sh         # Validation suite
│   ├── test-container.sh       # Container testing
│   └── security-scan.sh        # Security scanning
├── .claude/
│   └── settings.local.json     # Project-level permission config
├── docs/
│   ├── PROXY_SETUP.md          # Detailed proxy configuration guide
│   ├── SECURITY.md             # Security policy and best practices
│   └── SECURITY_AUDIT.md       # Security audit findings
└── .github/
    └── workflows/              # CI/CD pipelines
```

---

## Troubleshooting

### Login Troubleshooting Card (Browser Auth/localhost Callback)

**Symptom**: Authorization page keeps spinning after clicking Authorize.

**Quick Checklist**:
- VS Code left panel "PORTS" → Check if container port appears (e.g., 41521), mapped to `localhost:<same-port>`.
- Host browser or terminal direct connection to `http://127.0.0.1:<port>/` should return 404 (callback service is alive).
- Host proxy bypass must include: `localhost, 127.0.0.1, ::1, host.docker.internal` (to avoid proxy/IPv6 interference).

**Detailed Steps & Common Proxy Examples** (Shadowrocket/Clash/Surge/SwitchyOmega/PAC): See docs/PROXY_SETUP.md section "Host Bypass (localhost Callback Required Reading)".

---

### Quick Troubleshooting Card: Opening Project (Workspace does not exist)

**Recommended Startup Method**: `scripts/open-project.sh /path/to/your/project` (opens independent VS Code process for each project, ensuring `PROJECT_PATH` inheritance).

**Manual Method**: From terminal execute `export PROJECT_PATH=/path/to/your/project && code /path/to/universal-devcontainer` (don't launch VS Code from Dock).

**After Changes Rebuild**: VS Code → "Dev Containers: Rebuild Without Cache".

**macOS Path Sharing**: Docker Desktop → Settings → Resources → File Sharing includes project parent directory (e.g., `/Users`).

**Quick Self-Check**:
- Host: `echo $PROJECT_PATH`, `test -d "$PROJECT_PATH" && echo OK || echo MISSING`
- Inside container: Check startup banner (MOTD) or `grep ' /workspace ' /proc/mounts` to verify mount; script path is `/universal/.devcontainer/...`.

---

### Issue: Container Cannot Access Internet

**Checklist**:
1. Firewall blocking needed domain? → Add to `EXTRA_ALLOW_DOMAINS`
2. In restricted network? → Configure `HOST_PROXY_URL`, see [docs/PROXY_SETUP.md](docs/PROXY_SETUP.md)
3. Docker file sharing permissions (macOS): Docker Desktop → Resources → File Sharing includes `/Users`

---

### Issue: Claude Code Plugin Not Found

```bash
# Check marketplace configuration
claude /plugins marketplaces

# Re-run bootstrap
bash .devcontainer/bootstrap-claude.sh

# Check network
curl -I https://api.github.com
```

---

### Issue: Path Permission Error (macOS/Linux)

```bash
# Ensure parent directories are traversable
chmod o+rx /Users/<username>
chmod o+rx /Users/<username>/developer
chmod o+rx /Users/<username>/developer/<project>
```

---

### Issue: extends Cannot Find Config File

**Symptom**: Shows "missing image information"

**Solution**:
- **Method 1**: Use `github:owner/repo` instead of `file:relative-path`
- **Method 2**: Check if relative path is correct (path from project root to config file)
- **Method 3**: Use Method 1 (VS Code UI flow), no extends needed

---

### Issue: Authorization Page Keeps Spinning (OAuth localhost Callback)

**Symptom**: After opening `https://claude.ai/oauth/authorize?...redirect_uri=http://localhost:<random-port>/callback` and clicking Authorize, page keeps loading.

**Root Cause**: Callback service listens on `127.0.0.1:<random-port>` inside container, while browser on host accesses `localhost:<random-port>`. Without port forwarding, host's local loopback cannot reach container, callback request fails.

**Solution**:
- **Built-in**: `devcontainer.json` enables dynamic auto port forwarding (`portsAttributes.otherPortsAttributes` + `remote.autoForwardPorts=true`). When callback port listening appears, VS Code automatically forwards container port to same port on host; usually no manual action needed.
- **If still failing**:
  - Observe port number in auth URL (e.g., `63497`), manually Forward that port in VS Code left panel "PORTS".
  - Or in container run `ss -lntp | grep <port>` to confirm listening before forwarding.
  - **Workaround**: Set `CLAUDE_LOGIN_METHOD=console` and provide `ANTHROPIC_API_KEY`, switch to console/API Key login, bypassing browser local callback.

---

### Issue: Startup Shows "Workspace does not exist"

**Cause**: Host VS Code process didn't inherit `PROJECT_PATH`, or Docker Desktop didn't share that path, causing `/workspace` mount to fail.

**Solution**:
- **Recommended**: Use script to start: `scripts/open-project.sh <your-project-path>` (script starts independent VS Code instance, inherits environment variables).
- Or configure in VS Code user settings:
  ```jsonc
  {
    "dev.containers.defaultEnv": { "PROJECT_PATH": "/path/to/your/project" }
  }
  ```
- **macOS**: Docker Desktop → Settings → Resources → File Sharing, ensure includes `/Users` or your project parent directory.
- **If still failing**: First verify: `echo $PROJECT_PATH && test -d "$PROJECT_PATH" && echo OK || echo MISSING`.

---

## Security Notice ⚠️

- **Bypass mode** has no manual confirmation, use **only in trusted projects**
- Firewall denies all outbound connections by default, only whitelisted domains accessible
- Protected sensitive files: `.env*`, `secrets/**`, `id_rsa`, `id_ed25519`
- Container requires `--cap-add=NET_ADMIN` permission to manage firewall
- **Read the security documentation**: [docs/SECURITY.md](docs/SECURITY.md)

For more secure modes: Manually configure as shown in examples above.

---

## Common Use Cases

### Scenario 1: Quick Trial (Temporary Project)
→ Use **Method 1** (UI flow), no file creation needed

### Scenario 2: Team Collaboration Project
→ Use **Method 2** (project config), commit `.devcontainer/devcontainer.json` to repository

### Scenario 3: Multiple Personal Projects
→ Use **Method 3** (script assistance), quickly generate config for each project

### Scenario 4: Enterprise Restricted Network
→ Configure proxy first (see [docs/PROXY_SETUP.md](docs/PROXY_SETUP.md)), then use any method

---

## Validation and Testing

This project includes comprehensive validation and testing tools:

```bash
# Run all validations (JSON, shell syntax, secrets, file permissions)
./scripts/validate-all.sh

# Test container build and functionality
./scripts/test-container.sh

# Run security scan (Trivy, secret detection, capability review)
./scripts/security-scan.sh
```

**CI/CD**: Automated testing runs on every push via GitHub Actions:
- Configuration validation
- Container build testing
- Security scanning
- ShellCheck linting

---

## Roadmap

This project follows a multi-phase implementation plan. See [IMPLEMENTATION_PLAN.md](IMPLEMENTATION_PLAN.md) for details.

**Upcoming Features**:
- **Phase 1** (v2.1.0 - Q1 2025): Security hardening, CI/CD, English docs ✅
- **Phase 2** (v2.2.0 - Q2 2025): Dev Container Template, modular Features
- **Phase 3** (v2.2.0): Pre-built images, performance optimization
- **Phase 4** (v3.0.0 - Q3 2025): Framework examples, enhanced modes
- **Phase 5** (v3.0.0): Multi-container support, project generator
- **Phase 6** (Ongoing): Community building, video tutorials

---

## Changelog

### v2.0.0 (Simplified Version) — January 2025

**Breaking Changes** (Improved Usability):
- ✅ Uses **workspaceMount** to dynamically mount projects (no longer relies on extends)
- ✅ Simplified script logic (reduced from 71 to 65 lines)
- ✅ Removed all unstable extends-related code
- ✅ One container serves all projects

---

## Contributing

Contributions are welcome! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

**Before contributing**:
1. Read the security policy: [docs/SECURITY.md](docs/SECURITY.md)
2. Review the implementation plan: [IMPLEMENTATION_PLAN.md](IMPLEMENTATION_PLAN.md)
3. Run validation: `./scripts/validate-all.sh`
4. Follow commit message conventions

---

## References

- [VS Code Dev Containers Official Documentation](https://code.visualstudio.com/docs/devcontainers/containers)
- [Dev Container Specification](https://containers.dev/)
- [Claude Code Documentation](https://code.claude.com/docs)
- [Docker Security Best Practices](https://docs.docker.com/engine/security/)
- [Implementation Plan](IMPLEMENTATION_PLAN.md)
- [Quick Reference Guide](IMPLEMENTATION_QUICK_REFERENCE.md)

---

## License

MIT License — See `LICENSE` file for details

---

## Support

- 📖 Documentation: [docs/](docs/)
- 🐛 Issues: [GitHub Issues](https://github.com/xrf9268-hue/universal-devcontainer/issues)
- 💬 Discussions: [GitHub Discussions](https://github.com/xrf9268-hue/universal-devcontainer/discussions)
- 🔒 Security: See [docs/SECURITY.md](docs/SECURITY.md)

---

**Version**: 2.0.0
**Last Updated**: 2025-11-22
