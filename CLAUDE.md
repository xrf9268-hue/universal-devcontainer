# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Purpose

This is **Universal Dev Container** - a reusable Dev Container configuration that provides:
- Claude Code AI assistant pre-configured with authentication
- Network security via whitelist-based egress firewall
- Proxy/VPN support for restricted networks
- Development tools (Node.js LTS, Python 3.12, GitHub CLI)

**Key concept**: One configuration serves multiple projects by mounting external projects into `/workspace` while keeping the devcontainer config in this repo at `/universal`.

## Architecture

### Mount Strategy
- **This repo** → `/universal` (read-only) - contains devcontainer config & scripts
- **User's project** → `/workspace` - the actual development target
- **Claude config** → `~/.claude` - copied once from host's `~/.claude` during bootstrap

This separation allows one devcontainer configuration to serve unlimited projects without duplication.

### Container Lifecycle
1. **initializeCommand**: Validates `PROJECT_PATH` env var is set
2. **Build**: Installs base image with features (Node, Python, gh CLI)
3. **postCreateCommand**: Runs firewall setup + Claude bootstrap (one-time)
4. **postStartCommand**: Re-applies firewall rules (on every start)

### Key Scripts
- `.devcontainer/bootstrap-claude.sh` - Installs Claude Code CLI, merges host credentials, configures permissions
- `.devcontainer/init-firewall.sh` - Sets up iptables whitelist, detects proxy from env vars
- `scripts/open-project.sh` - Wrapper that sets `PROJECT_PATH` env and launches VS Code

## Common Development Commands

### Testing
```bash
# Validate JSON syntax
jq empty .devcontainer/devcontainer.json
jq empty .claude/settings.local.json

# Check shell scripts
bash -n scripts/*.sh .devcontainer/*.sh
shellcheck scripts/*.sh .devcontainer/*.sh

# Test Python examples (required before merging dependency changes)
./scripts/test-all-examples.sh

# Test individual example
cd examples/python-django && ./test.sh
```

### Using This Container to Develop Other Projects
```bash
# Method 1: Script (recommended)
./scripts/open-project.sh /path/to/your/project

# Method 2: Manual
export PROJECT_PATH=/path/to/your/project
code .
# Then: "Reopen in Container"
```

### Proxy Configuration
When behind corporate proxy/firewall:

1. **Host environment variables** (set before opening VS Code):
```bash
export HOST_PROXY_URL=http://host.docker.internal:1082
export NO_PROXY=localhost,127.0.0.1,host.docker.internal
```

2. **Container inherits** both uppercase and lowercase variants:
   - `HTTP_PROXY` / `http_proxy`
   - `HTTPS_PROXY` / `https_proxy`
   - `NO_PROXY` / `no_proxy`
   (Lowercase required for Node.js/Claude Code; uppercase for other tools)

3. **Firewall automatically allowlists** proxy port parsed from env vars

Important: SOCKS proxies are NOT supported by Claude Code. Use HTTP/HTTPS proxy only.

See `docs/PROXY_SETUP.md` for full proxy configuration guide including localhost bypass requirements for OAuth callbacks.

### Security

**Firewall whitelist** (`.devcontainer/init-firewall.sh:10-20`):
- npmjs.org, github.com (dev tools)
- claude.ai, api.anthropic.com, statsig.anthropic.com, sentry.io (Claude Code)
- Custom domains via `EXTRA_ALLOW_DOMAINS` env var

**Strict proxy mode** (`STRICT_PROXY_ONLY=1` default):
- Blocks ALL direct HTTPS except to proxy
- Requires proxy for Claude API access
- Prevents IP leakage that could trigger account bans

**Permission modes** (`.claude/presets/`):
- `dev.json` - bypassPermissions (default, auto-approve all actions)
- `safe.json` - ask mode (require approval for filesystem/network)
- Switch via `scripts/configure-claude-mode.sh`

## Project Structure

```
.devcontainer/
├── devcontainer.json       # Main config: mounts, env vars, features
├── Dockerfile              # Base image with proxy support
├── bootstrap-claude.sh     # Claude Code CLI installation & auth
├── init-firewall.sh        # iptables egress firewall
└── setup-proxy.sh          # Configure apt/npm/pip proxy (optional)

scripts/
├── open-project.sh         # Primary entry point for users
├── test-all-examples.sh    # Integration test runner
├── configure-claude-mode.sh # Switch permission modes
└── security-scan.sh        # Trivy/Bandit security checks

src/                        # Dev Container Features (published separately)
├── claude-code/            # Claude Code feature
├── firewall/               # Network firewall feature
└── features/               # Toolsets (database, cloud, k8s, etc.)

examples/                   # Framework integration examples
├── python-django/test.sh
├── python-fastapi/test.sh
├── nextjs-app/
└── multi-container/

docs/
├── PROXY_SETUP.md          # Proxy configuration guide
├── SECURITY.md             # Security best practices
└── TESTING.md              # Testing guide
```

## Making Changes

### Modifying Devcontainer Config
- `.devcontainer/devcontainer.json` controls all container behavior
- **remoteEnv** = env vars for VS Code & terminals
- **containerEnv** = env vars for entire container
- Both must include proxy vars (uppercase AND lowercase)
- After changes: rebuild container to test

### Adding/Updating Dependencies
**Python examples** (examples/python-*/requirements.txt):
1. Update version in requirements.txt
2. **MUST run tests**: `cd examples/python-django && ./test.sh`
3. Document CVEs fixed in commit message
4. Test for breaking changes

**Hash-pinned dependencies** (src/features/*/requirements-*.txt):
1. Download package: `pip download package==1.0.0 --no-deps`
2. Get hash: `pip hash package-1.0.0-py3-none-any.whl`
3. Update with `--hash=sha256:...` line
4. Test with `pip install --require-hashes`

### Adding Firewall Domains
Edit `.devcontainer/init-firewall.sh:10-20` DEFAULT_ALLOW_DOMAINS array.
Only add if absolutely necessary - default deny is intentional.

### Shell Script Standards
- Use `#!/usr/bin/env bash` (not sh)
- Add `set -euo pipefail`
- Quote all variables: `"$VAR"`
- Use `[[` not `[` for conditions
- Test with `bash -n script.sh` and `shellcheck`

## Environment Variables Reference

### Required (for shared config mode)
- `PROJECT_PATH` - Absolute path to user's project (auto-set by open-project.sh)

### Optional - Claude Authentication
- `CLAUDE_LOGIN_METHOD` - `claudeai` (default) | `console` | `api-key`
- `CLAUDE_ORG_UUID` - Force specific organization
- `ANTHROPIC_API_KEY` - API key (when using api-key method)

### Optional - Proxy/Network
- `HOST_PROXY_URL` - HTTP/HTTPS proxy URL (e.g., `http://host.docker.internal:1082`)
- `NO_PROXY` - Comma-separated bypass list
- `STRICT_PROXY_ONLY` - `1` (default, force proxy) | `0` (allow direct to whitelist)

### Optional - Container Behavior
- `TZ` - Timezone (default: `Asia/Shanghai`)
- `ENABLE_CLAUDE_SANDBOX` - `1` (sandbox commands) | `0` (default)

## Testing Strategy

### Before Committing
```bash
# 1. Validate syntax
jq empty .devcontainer/devcontainer.json
bash -n scripts/*.sh .devcontainer/*.sh

# 2. Test examples
./scripts/test-all-examples.sh

# 3. Rebuild container and verify features
# Dev Containers: Rebuild Container
claude /doctor
node -v && python3 --version
```

### CI Pipeline (.github/workflows/)
- **test-devcontainer.yml** - Validates JSON/shell syntax, file structure
- **test-python-examples.yml** - Runs Python example tests in CI
- **build-image.yml** - Builds and publishes prebuilt image
- **dependency-review.yml** - Security scanning for dependencies

### Example Test Scripts
Each example has a `test.sh` that:
1. Creates virtual environment
2. Installs dependencies
3. Verifies core functionality (e.g., Django migrations)
4. Runs security scans (Bandit, Safety)

Test failures block merges to ensure stability.

## Troubleshooting Common Issues

### Claude Code can't connect
1. Check proxy env vars: `env | grep -i proxy`
2. Verify lowercase variants exist (Node.js requirement)
3. Test proxy: `nc -vz host.docker.internal 1082`
4. Check firewall allows Claude domains: `sudo iptables -S OUTPUT`
5. Verify required domains in whitelist: api.anthropic.com, claude.ai, statsig.anthropic.com, sentry.io

### Project not mounted at /workspace
1. Verify `PROJECT_PATH` is set: `echo $PROJECT_PATH`
2. Check if directory shared with Docker (macOS: Docker Desktop → Settings → Resources → File Sharing)
3. Use `scripts/open-project.sh` instead of manual launch

### Firewall blocking legitimate traffic
1. Add domain to `EXTRA_ALLOW_DOMAINS` env var (temporary)
2. Or add to DEFAULT_ALLOW_DOMAINS in init-firewall.sh
3. Or disable strict mode: `export STRICT_PROXY_ONLY=0`

### OAuth/login callback hanging
Host proxy must bypass localhost. Add to proxy rules:
- `localhost`, `127.0.0.1`, `::1` → DIRECT
- Container uses VS Code port forwarding for callbacks

## Dev Container Features

This repo publishes reusable features to GitHub Container Registry:
- `ghcr.io/xrf9268-hue/features/claude-code` - Claude Code installer
- `ghcr.io/xrf9268-hue/features/firewall` - Network firewall
- `ghcr.io/xrf9268-hue/features/toolset-*` - Tool bundles

Other projects can use these features by referencing them in devcontainer.json without copying this entire repo.

See `src/*/README.md` for feature-specific documentation.
