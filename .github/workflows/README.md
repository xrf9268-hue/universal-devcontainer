# CI/CD Workflows

This directory contains GitHub Actions workflows for automated testing, security scanning, and release management.

## Active Workflows

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
- **Trivy Image Scan**: Vulnerability scanning of container images (HIGH/CRITICAL)
- **Trivy FS Scan**: Filesystem vulnerability scanning (all dependencies)
- **Secret Scan**: TruffleHog secret detection in git history
- **CodeQL**: Static code analysis for security vulnerabilities
- **OpenSSF Scorecard**: Repository security best practices assessment

**Comprehensive Coverage**:
- ✅ OS package vulnerabilities (Trivy)
- ✅ Application dependency vulnerabilities (Trivy)
- ✅ npm, pip, Go modules, etc. (Trivy supports 20+ ecosystems)
- ✅ License compliance can be added to Trivy config
- ✅ Secret detection across entire history
- ✅ Static code analysis (CodeQL)
- ✅ Repository security posture (Scorecard)

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

## Optional Workflows

### `dependency-review.optional.yml` - Enhanced Dependency Analysis

**Status**: ⚠️ **Disabled by default** (requires manual activation)

**Why Optional**:
- Requires **"Dependency graph"** feature enabled (admin access required)
- Not available on forked repositories by default
- Main `security-scan.yml` already provides comprehensive dependency scanning via Trivy
- This adds: License compliance enforcement, GitHub-specific dependency analysis

**Requirements**:
1. Public repository, OR
2. Private repository with GitHub Advanced Security license
3. Dependency graph enabled: Settings → Code security → Dependency graph

**To Enable**:
```bash
# Rename the file to activate
mv .github/workflows/dependency-review.optional.yml \
   .github/workflows/dependency-review.yml

git add .github/workflows/dependency-review.yml
git commit -m "Enable dependency review workflow"
git push
```

**What It Adds** (if enabled):
- License compliance checking (blocks GPL-3.0, AGPL-3.0, etc.)
- PR comments with dependency changes
- Additional vulnerability database (complements Trivy)
- GitHub-specific security advisories

**Not Needed If**:
- You don't have admin access to enable dependency graph
- Repository is a fork (dependency graph disabled by default)
- Trivy scanning is sufficient for your needs (it usually is!)

---

## Common Questions

### Why was Dependency Review removed from the main workflow?

**Research Finding**: This is a [known issue (#164)](https://github.com/actions/dependency-review-action/issues/164)

**Problem**:
- Dependency graph is **disabled by default on forked repositories**
- Requires **admin permissions** to enable
- No way to conditionally check if it's available
- Even with `continue-on-error: true`, shows confusing error messages

**Solution** (following best practices):
- ❌ Removed from main `security-scan.yml` workflow
- ✅ Moved to optional `dependency-review.optional.yml` file
- ✅ Users with access can easily enable it by renaming the file
- ✅ Main workflow provides comprehensive scanning via Trivy anyway

**What You're NOT Missing**:
- Trivy scans **20+ dependency ecosystems** (npm, pip, Go, Rust, etc.)
- Trivy detects **HIGH and CRITICAL vulnerabilities**
- Trivy can enforce license compliance (if configured)
- This is **more comprehensive** than dependency-review in many cases

**Official Sources**:
- [GitHub Issue: Unclear error when dependency graph disabled](https://github.com/actions/dependency-review-action/issues/164)
- [GitHub Docs: About dependency review](https://docs.github.com/en/code-security/supply-chain-security/understanding-your-software-supply-chain/about-dependency-review)
- Best practice: Don't include features requiring admin permissions in default workflows

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
