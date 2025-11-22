# CI/CD Workflows

This directory contains GitHub Actions workflows for automated testing, security scanning, and release management.

## Workflows

### 1. `test-devcontainer.yml` - Continuous Integration

**Triggers**: Push to main/claude branches, Pull requests to main

**Jobs**:
- **Validate**: JSON and shell script validation
- **ShellCheck**: Shell script linting
- **Build**: Container build testing
- **Test Scripts**: Validation script execution
- **Security Check**: Secret detection and documentation verification
- **Test Matrix**: Multi-scenario testing (standard/strict proxy modes)

**Purpose**: Ensures code quality and configuration validity on every change.

---

### 2. `security-scan.yml` - Security Scanning

**Triggers**: Push/PR to main, Weekly schedule (Mon 9 AM UTC), Branch protection changes

**Jobs**:
- **Trivy Image Scan**: Vulnerability scanning of container images
- **Trivy FS Scan**: Filesystem vulnerability scanning
- **Secret Scan**: TruffleHog secret detection in git history
- **CodeQL**: Static code analysis
- **OpenSSF Scorecard**: Repository security best practices (main branch only)
- **Dependency Review**: Dependency vulnerability analysis (optional)

**Optional Features**:
- **Dependency Review** requires "Dependency graph" enabled in repository settings
  - Path: Settings → Code security and analysis → Dependency graph
  - If disabled: Job shows warning but workflow continues (not a failure)
  - Alternative: Trivy provides comprehensive dependency scanning

---

### 3. `release.yml` - Release Automation

**Triggers**: Release published, Manual workflow dispatch

**Jobs**:
- **Validate Release**: Checks version format and security documentation
- **Build Image**: Multi-architecture container build (amd64, arm64)
- **Security Scan Release**: Trivy scan of release images (fails on critical/high)
- **Create Release Notes**: Generates changelog and installation instructions
- **Publish Template**: Hooks for template publication (Phase 2)

**Purpose**: Automates release process with security verification.

---

## Common Questions

### Why does "Dependency Review" show an error?

The dependency-review job requires the "Dependency graph" feature to be enabled in repository settings. This is an **optional enhancement** - if not enabled:

- ✅ Workflow continues successfully (not a failure)
- ✅ Trivy provides comprehensive dependency vulnerability scanning
- ✅ CodeQL provides additional security analysis

**To enable** (optional, requires admin access):
1. Go to Repository Settings
2. Navigate to "Code security and analysis"
3. Enable "Dependency graph"

**Why it's optional**:
- Not available on all repository types
- Requires admin permissions
- Trivy already provides thorough dependency scanning
- Makes workflows portable across different repository configurations

---

### Why does "OpenSSF Scorecard" skip on feature branches?

OpenSSF Scorecard analyzes **repository-level** security (branch protection, CI/CD presence, security policies), not branch-specific code. Running on every feature branch produces identical results.

**It runs on**:
- ✅ Weekly schedule (ongoing monitoring)
- ✅ Push to main branch
- ✅ Pull requests to main (shows security impact)
- ✅ Branch protection rule changes
- ❌ Feature branch pushes (redundant)

This follows [official best practices](https://github.com/ossf/scorecard-action).

---

## Workflow Status Interpretation

### Expected Results

```
Test Dev Container Workflow:
✅ Validation: success
✅ ShellCheck: success
✅ Build: success
✅ Scripts: success
✅ Security: success
✅ Test Matrix: success

Security Scan Workflow:
✅ Trivy Image Scan: success
✅ Trivy FS Scan: success
✅ Secret Scan: success
✅ CodeQL: success
⏭️ Scorecard: skipped (feature branches) OR ✅ success (main/PRs)
⚠️ Dependency Review: warning (optional feature) OR ✅ success (if enabled)
```

### What Each Status Means

- ✅ **success**: Job passed
- ⚠️ **warning**: Job encountered expected issue but didn't fail workflow
- ⏭️ **skipped**: Job intentionally skipped (condition not met)
- ❌ **failure**: Job failed (workflow fails)

---

## Local Testing

Before pushing, run local validation:

```bash
# Validate all configurations
./scripts/validate-all.sh

# Test container build (requires Docker)
./scripts/test-container.sh

# Run security scan (requires Docker)
./scripts/security-scan.sh
```

---

## Debugging Workflow Failures

### Validation Failures
```bash
# Check JSON syntax
jq empty .devcontainer/devcontainer.json

# Check shell scripts
bash -n scripts/*.sh .devcontainer/*.sh

# Run shellcheck
shellcheck scripts/*.sh .devcontainer/*.sh
```

### Build Failures
```bash
# Build container locally
docker build -t test -f .devcontainer/Dockerfile.ci .devcontainer/

# Test with devcontainer CLI
devcontainer build --workspace-folder .
```

### Security Scan Failures
```bash
# Run Trivy locally
trivy image --severity HIGH,CRITICAL <image-name>

# Check for secrets
git ls-files | xargs grep -E "sk-ant-api-[a-zA-Z0-9]{95}"
```

---

## Adding New Workflows

When adding new workflows:

1. **Follow naming convention**: `kebab-case.yml`
2. **Add description** in this README
3. **Use caching** for dependencies when possible
4. **Set timeouts** to prevent hanging jobs
5. **Document required secrets** and permissions
6. **Test locally** before committing

---

## Workflow Permissions

Workflows use minimal required permissions:

- **Read**: Repository contents, actions
- **Write**: Security events (SARIF uploads), packages (releases)
- **Id-token**: OIDC for Scorecard

See individual workflow files for specific permission requirements.

---

## Related Documentation

- [Implementation Plan](../IMPLEMENTATION_PLAN.md) - Full development roadmap
- [Security Policy](../docs/SECURITY.md) - Security practices and policies
- [Security Audit](../docs/SECURITY_AUDIT.md) - Security assessment findings

---

**Last Updated**: 2025-11-22
**Maintained By**: Universal Dev Container Team
