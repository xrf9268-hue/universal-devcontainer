# Security Policy

## Overview

This document describes the security model, threat analysis, and best practices for the Universal Dev Container with Claude Code.

**Last Updated**: 2025-11-22
**Version**: 2.0.0

---

## Table of Contents

- [Security Model](#security-model)
- [Container Capabilities](#container-capabilities)
- [Network Security](#network-security)
- [Secret Management](#secret-management)
- [Threat Model](#threat-model)
- [Security Best Practices](#security-best-practices)
- [Reporting Security Issues](#reporting-security-issues)

---

## Security Model

### Trust Boundaries

```
┌─────────────────────────────────────────────────┐
│ Host System (Trusted)                           │
│  ├─ Docker Daemon                               │
│  ├─ User Home Directory (~/.claude)             │
│  └─ Project Files (${PROJECT_PATH})             │
└─────────────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────────────┐
│ Container (Semi-Trusted Sandbox)                │
│  ├─ Development Tools (Node, Python, etc.)      │
│  ├─ Claude Code CLI                             │
│  ├─ Network Firewall (iptables)                 │
│  └─ User Code Execution                         │
└─────────────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────────────┐
│ External Network (Untrusted)                    │
│  ├─ npm Registry                                │
│  ├─ GitHub                                      │
│  ├─ Anthropic API                               │
│  └─ Other Internet Services                     │
└─────────────────────────────────────────────────┘
```

### Security Layers

1. **Container Isolation**: Docker container provides process and filesystem isolation
2. **Network Firewall**: iptables-based whitelist for outbound connections
3. **Read-Only Mounts**: Host Claude credentials mounted read-only
4. **Non-Root User**: Runs as `vscode` user (non-root) inside container
5. **Capability Restrictions**: Only NET_ADMIN and NET_RAW capabilities added

---

## Container Capabilities

### Required Capabilities

The container requires elevated capabilities for specific functionality:

#### 1. `NET_ADMIN` (Required for Firewall)

**Purpose**: Manage iptables rules for network filtering

**Used By**: `init-firewall.sh` script

**Justification**:
- Implements egress firewall to restrict outbound connections
- Enforces whitelist-based network access control
- Required for `iptables` command execution

**Security Impact**:
- ⚠️ **Medium Risk**: Allows container to modify network rules
- ✅ **Mitigated**: Container is ephemeral; rules don't affect host
- ✅ **Mitigated**: iptables rules only apply within container namespace

**Alternative Considered**:
- Docker network policies (not granular enough for domain whitelisting)
- Host-level firewall (requires host system modification)
- No firewall (rejected - reduces security posture)

**Recommendation**: ✅ **Keep** - Essential for security feature

---

#### 2. `NET_RAW` (Review Needed)

**Purpose**: Access to raw sockets

**Justification**:
- Originally added alongside NET_ADMIN
- May be required for low-level network operations

**Security Impact**:
- ⚠️ **Medium Risk**: Allows crafting raw network packets
- ⚠️ **Concern**: Not explicitly used by current scripts

**Alternative**:
- Remove capability and test if firewall still works
- Only add back if specific tool requires it

**Recommendation**: ⚠️ **Review** - Test if removal breaks functionality

**Action Item**:
```bash
# Test without NET_RAW
sed -i '/NET_RAW/d' .devcontainer/devcontainer.json
# Rebuild and verify iptables still works
```

---

### Capabilities NOT Used

The following capabilities are intentionally **NOT** granted:

- ❌ `--privileged` - Full access to host (dangerous)
- ❌ `SYS_ADMIN` - System administration (too broad)
- ❌ `CAP_SYS_PTRACE` - Process debugging (privacy risk)
- ❌ `CAP_SYS_MODULE` - Load kernel modules (dangerous)

---

## Network Security

### Firewall Architecture

The container implements a **default-deny egress firewall** with domain whitelisting.

#### Firewall Modes

##### 1. **Standard Mode** (Default)
```bash
STRICT_PROXY_ONLY=0
```

**Behavior**:
- Default DENY all outbound connections
- ALLOW whitelisted domains on port 443 (HTTPS)
- ALLOW DNS queries
- ALLOW proxy connections (if configured)
- ALLOW SSH to GitHub only (port 22)
- ALLOW established/related connections

**Whitelisted Domains**:
```bash
registry.npmjs.org  # npm packages
npmjs.org           # npm registry
github.com          # Git operations
api.github.com      # GitHub API
objects.githubusercontent.com  # GitHub content
claude.ai           # Claude authentication
api.anthropic.com   # Claude API
console.anthropic.com  # Claude console
```

**Add Custom Domains**:
```bash
export EXTRA_ALLOW_DOMAINS="example.com api.myservice.io"
```

---

##### 2. **Strict Proxy Mode**
```bash
STRICT_PROXY_ONLY=1
```

**Behavior**:
- Default DENY all outbound connections
- ALLOW ONLY proxy connections
- DENY direct domain access (domains NOT whitelisted)
- Forces all traffic through corporate proxy

**Use Case**: Enterprise environments with mandatory proxy

**Configuration**:
```bash
export STRICT_PROXY_ONLY=1
export HTTP_PROXY=http://proxy.company.com:8080
export HTTPS_PROXY=http://proxy.company.com:8080
```

---

##### 3. **Permissive SSH Mode**
```bash
ALLOW_SSH_ANY=1
```

**Behavior**:
- Allows SSH (port 22) to any destination
- Useful for accessing private Git repositories

**Security Warning**: Only enable if you trust all SSH destinations

---

### Proxy Support

The firewall automatically detects and allows proxy connections:

```bash
# Proxy detected from environment
HTTP_PROXY=http://proxy.example.com:3128
HTTPS_PROXY=http://proxy.example.com:3128

# Firewall automatically:
# 1. Parses proxy hostname and port
# 2. Resolves proxy IP addresses
# 3. Adds iptables rules for proxy access
```

**Supported Proxy Formats**:
- `http://proxy.example.com:8080`
- `http://user:pass@proxy.example.com:8080`
- `http://[::1]:8080` (IPv6)

---

### Network Attack Vectors

| Attack Vector | Mitigation | Risk Level |
|--------------|------------|------------|
| **Outbound Data Exfiltration** | Egress firewall blocks non-whitelisted destinations | 🟡 Medium |
| **Malicious npm Package** | Whitelist only npm registry; audit dependencies | 🟢 Low-Medium |
| **DNS Poisoning** | Uses host DNS; consider DNSSEC | 🟢 Low |
| **Man-in-the-Middle** | HTTPS enforced for whitelisted domains | 🟢 Low |
| **Container Escape** | Docker isolation; non-root user | 🟡 Medium |

---

## Secret Management

### Credentials Storage

#### ✅ **Secure Practices**

1. **Host Credentials (Read-Only)**
   ```json
   "mounts": [
     "source=${localEnv:HOME}/.claude,target=/host-claude,type=bind,readonly"
   ]
   ```
   - Claude credentials mounted **read-only** from host
   - Container cannot modify host credentials
   - Credentials never stored in container image

2. **Environment Variables**
   ```bash
   export ANTHROPIC_API_KEY=sk-ant-...
   ```
   - Pass secrets via environment variables
   - Not committed to git
   - Loaded dynamically at runtime

3. **Gitignore Protection**
   ```gitignore
   .env
   .env.*
   .claude/credentials*
   *.key
   *.pem
   secrets/
   ```

---

#### ❌ **Anti-Patterns to Avoid**

1. **Hardcoded Secrets**
   ```bash
   # ❌ NEVER DO THIS
   ANTHROPIC_API_KEY="sk-ant-actual-key-here"  # Don't hardcode!
   ```

2. **Committed Credentials**
   ```bash
   # ❌ NEVER COMMIT
   git add .env  # Don't commit .env files!
   ```

3. **Secrets in Logs**
   ```bash
   # ❌ Don't log secrets
   echo "API Key: $ANTHROPIC_API_KEY"  # Avoid logging
   ```

---

### Claude Code Permissions

#### ⚠️ **bypassPermissions Mode**

The default configuration uses `bypassPermissions: true`:

**Risks**:
- Claude can read, write, and execute files without prompts
- Suitable ONLY for **trusted repositories**
- Should be used in **isolated environments** (containers)

**Mitigation**:
- ✅ Container provides isolation layer
- ✅ Egress firewall limits data exfiltration
- ✅ Read-only mount for host credentials
- ✅ User can disable bypass mode if needed

**Disable Bypass Mode**:
```json
// .claude/settings.json
{
  "bypassPermissions": false,
  "permissions": {
    "requireApproval": {
      "write": ["*"],
      "execute": ["*"],
      "network": ["*"]
    }
  }
}
```

---

### Sensitive File Protection

The bootstrap script configures Claude Code to avoid sensitive files:

```json
"permissions": {
  "deny": {
    "read": [
      ".env*",
      "secrets/**",
      "*.key",
      "*.pem",
      "credentials.*"
    ]
  }
}
```

**Note**: This is defense-in-depth; still keep secrets out of workspace!

---

## Threat Model

### In-Scope Threats

| Threat | Likelihood | Impact | Mitigation |
|--------|-----------|--------|------------|
| **Malicious npm package** | Medium | High | Firewall limits destinations; audit deps |
| **Accidental secret commit** | High | High | Pre-commit hooks; .gitignore; education |
| **Outbound data leak** | Low | Medium | Egress firewall; domain whitelist |
| **Compromised dependency** | Medium | High | Regular updates; Trivy scanning |
| **Container escape** | Low | Critical | Docker isolation; capability restrictions |

---

### Out-of-Scope Threats

The following are **NOT** protected by this configuration:

- ❌ **Compromised host system** - Container security relies on host integrity
- ❌ **Malicious Docker images** - Always use trusted base images
- ❌ **Physical access attacks** - Requires host-level security
- ❌ **Side-channel attacks** - Not designed for high-security environments
- ❌ **Kernel vulnerabilities** - Keep host kernel updated

---

### Attack Scenarios

#### Scenario 1: Malicious npm Package

**Attack**: Developer installs malicious package that tries to exfiltrate secrets

**Mitigation**:
1. ✅ Firewall blocks connections to non-whitelisted domains
2. ✅ Sensitive files denied in Claude settings
3. ✅ Package audit with `npm audit`
4. ⚠️ If package connects to npm/GitHub (whitelisted), data could leak

**Recommendation**:
- Audit dependencies before installation
- Use `npm audit` and Trivy scanning
- Consider additional allowlist restrictions for sensitive projects

---

#### Scenario 2: Accidental Secret Commit

**Attack**: Developer accidentally commits `.env` file with API keys

**Mitigation**:
1. ✅ `.gitignore` prevents tracking `.env*` files
2. ✅ Pre-commit hooks can detect secrets (TODO: Add in Phase 1)
3. ✅ Validation script warns about potential secrets

**Recommendation**:
- Add pre-commit hook with secret detection
- Use tools like `git-secrets` or `trufflehog`
- Rotate credentials if accidentally committed

---

#### Scenario 3: Container Escape

**Attack**: Attacker exploits Docker vulnerability to escape container

**Mitigation**:
1. ✅ Docker provides kernel-level isolation
2. ✅ Non-root user inside container
3. ✅ Limited capabilities (only NET_ADMIN, NET_RAW)
4. ✅ No privileged mode
5. ⚠️ Still relies on Docker/kernel security

**Recommendation**:
- Keep Docker Engine updated
- Keep host kernel updated
- Use Docker security scanning
- Don't use for highly sensitive workloads

---

## Security Best Practices

### For Users

#### 1. **Environment Setup**

```bash
# ✅ DO: Set secrets via environment
export ANTHROPIC_API_KEY=sk-ant-...

# ✅ DO: Use separate .env files (gitignored)
cat > .env <<EOF
ANTHROPIC_API_KEY=sk-ant-...
DATABASE_URL=postgresql://...
EOF

# ❌ DON'T: Hardcode in scripts
```

---

#### 2. **Project Trust**

- ✅ Only use `bypassPermissions: true` for **your own projects**
- ✅ For untrusted projects, disable bypass mode
- ✅ Review code before allowing Claude to modify it
- ✅ Use strict proxy mode in corporate environments

---

#### 3. **Dependency Management**

```bash
# ✅ Audit before installing
npm audit
npm audit fix

# ✅ Scan for vulnerabilities
trivy fs .

# ✅ Keep dependencies updated
npm update
```

---

#### 4. **Network Configuration**

```bash
# ✅ For sensitive projects, use strict mode
export STRICT_PROXY_ONLY=1

# ✅ Limit additional domains
export EXTRA_ALLOW_DOMAINS="api.mycompany.com"

# ❌ DON'T: Disable firewall
# Don't remove NET_ADMIN capability
```

---

### For Contributors

#### 1. **Code Review**

- ✅ Review all PRs for security implications
- ✅ Check for hardcoded credentials
- ✅ Verify firewall rules are maintained
- ✅ Test capability changes thoroughly

---

#### 2. **Adding Dependencies**

```bash
# ✅ Scan new dependencies
trivy image <new-base-image>

# ✅ Pin versions
"features": {
  "ghcr.io/devcontainers/features/node:1": {
    "version": "20.10.0"  // Pinned
  }
}

# ❌ DON'T: Use "latest" tag
```

---

#### 3. **Testing Security Features**

```bash
# Test firewall blocks non-whitelisted domains
docker exec <container> curl https://evil.com  # Should fail

# Test firewall allows whitelisted domains
docker exec <container> curl https://api.github.com  # Should work

# Test secrets aren't logged
docker logs <container> | grep -i "sk-ant"  # Should find nothing
```

---

## Vulnerability Disclosure

### Supported Versions

| Version | Supported          |
| ------- | ------------------ |
| 2.x.x   | ✅ Active support  |
| 1.x.x   | ⚠️ Security fixes only |
| < 1.0   | ❌ Not supported   |

---

### Reporting Security Issues

**DO NOT** open public GitHub issues for security vulnerabilities.

**Instead**:
1. Email: [Your security contact email]
2. Use GitHub Security Advisories (if available)
3. Provide:
   - Description of vulnerability
   - Steps to reproduce
   - Potential impact
   - Suggested fix (if any)

**Response Timeline**:
- Acknowledgment: Within 48 hours
- Initial assessment: Within 1 week
- Fix timeline: Based on severity
- Public disclosure: After fix is available

---

## Security Checklist

### Before Using This Container

- [ ] Reviewed security model and threat analysis
- [ ] Understand container capability requirements
- [ ] Configured appropriate firewall mode (standard/strict)
- [ ] Added `.env` and secrets to `.gitignore`
- [ ] Decided on Claude permission mode (bypass vs. safe)
- [ ] Reviewed whitelisted domains
- [ ] Configured proxy if required
- [ ] Understand that `bypassPermissions` is for trusted repos only

---

### Regular Security Maintenance

- [ ] Run `./scripts/security-scan.sh` regularly
- [ ] Update base image and dependencies monthly
- [ ] Review Docker/kernel security advisories
- [ ] Audit newly added dependencies
- [ ] Rotate API keys every 90 days (recommended)
- [ ] Review firewall whitelist quarterly
- [ ] Check for container escape vulnerabilities

---

## Additional Resources

- [Docker Security Best Practices](https://docs.docker.com/engine/security/)
- [Dev Container Security](https://containers.dev/guide/security)
- [Claude Code Security](https://code.claude.com/docs/security)
- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
- [CIS Docker Benchmark](https://www.cisecurity.org/benchmark/docker)

---

## Compliance Considerations

### GDPR

- User data processed only in container (not persisted in image)
- Claude API subject to Anthropic's privacy policy
- Consider using Claude for Business for enhanced compliance

### SOC 2

- Audit logging available (TODO: Implement in Phase 5)
- Network controls via firewall
- Credential management via environment variables

### HIPAA

- ⚠️ **Not HIPAA-ready by default**
- Would require: Enhanced encryption, audit logging, BAA with Anthropic
- Consider dedicated compliance configuration (Phase 5)

---

**Document Version**: 1.0
**Last Review**: 2025-11-22
**Next Review**: 2025-12-22
