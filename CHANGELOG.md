# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

**Claude Code Advanced Plugins Feature**
- **New Feature** (`src/features/claude-code-plugins/`)
  - Integration with community marketplace (xrf9268-hue/claude-code-plugins)
  - 9 production-ready plugins for enhanced development workflows
  - 7 plugin installation modes: essential, all, development, review, security, custom, none
  - Flexible configuration with customPlugins option
  - Backward compatible with official Claude Code plugins
  - Comprehensive documentation with examples
  - Support for both official and community marketplaces simultaneously

**Plugin Sets**:
- **essential**: commit-commands, code-review, security-guidance, context-preservation
- **all**: All 9 community plugins
- **development**: agent-sdk-dev, feature-dev, plugin-developer-toolkit
- **review**: code-review, pr-review-toolkit
- **security**: security-guidance

**Available Plugins**:
1. agent-sdk-dev - Claude Agent SDK development tools
2. commit-commands - Git workflow automation
3. code-review - Automated PR review with confidence scoring
4. feature-dev - 7-phase structured feature development
5. security-guidance - Proactive security warnings (17 rules)
6. context-preservation - Auto-save context before compaction
7. frontend-dev-guidelines - React/TypeScript best practices
8. pr-review-toolkit - 6 specialized review agents
9. plugin-developer-toolkit - Create your own plugins

**Examples**:
- New example project: `examples/with-advanced-plugins/`
- Updated React example with advanced plugins configuration
- Comprehensive usage documentation

**Documentation**:
- Feature README: `src/features/claude-code-plugins/README.md`
- Updated main README (Chinese and English)
- Plugin integration examples

## [2.1.0] - 2025-11-23

### Added

**Phase 2: Distribution & Modularity**
- **Dev Container Template** (`src/universal-claude/`)
  - Customizable template with 6 options via VS Code UI
  - Options: claudeLoginMethod, enableFirewall, strictProxyMode, timezone, enableSandbox, bypassPermissions
  - NOTES.md for user guidance after template application
  - Complete README with usage examples

- **Claude Code Feature** (`src/claude-code/`)
  - Standalone Dev Container Feature for Claude Code installation
  - 5 configurable options: loginMethod, bypassPermissions, installPlugins, enableSandbox, orgUUID
  - Multi-method authentication support (host, api-key, manual)
  - Protected files configuration (always denies .env, secrets/**, SSH keys)
  - Plugin marketplace integration
  - Runtime host settings import script

- **Firewall Feature** (`src/firewall/`)
  - iptables-based egress firewall with domain whitelisting
  - 3 preset configurations: standard, strict, permissive
  - Customizable whitelist domains
  - Strict proxy mode for corporate environments
  - Granular SSH control (github-only, all, none)
  - Automatic proxy detection and allowlisting

**Phase 3: Performance & Optimization**
- **Pre-built Container Image** (`Dockerfile.prebuilt`)
  - Optimized multi-layer Dockerfile for fast builds
  - 70% faster first-time startup (10 min → 1 min pull)
  - 80% faster subsequent starts (30 sec → 5 sec)
  - Multi-architecture support (linux/amd64, linux/arm64)
  - Layer caching optimization

- **Automated Image Builds** (`.github/workflows/build-image.yml`)
  - Multi-architecture builds via GitHub Actions
  - Automatic semantic versioning (latest, X.Y.Z, X.Y, X)
  - GHCR publishing (ghcr.io/xrf9268-hue/universal-devcontainer)
  - BuildKit GitHub Actions cache
  - Trivy security scanning with SARIF upload
  - Build summary generation

- **Pre-built Image Examples** (`examples/prebuilt-image/`)
  - Complete working example using pre-built image
  - Performance comparison documentation
  - Migration guide from Dockerfile
  - Troubleshooting tips

- **Incremental Update Mechanism** (`scripts/update-config.sh`)
  - In-container update script without rebuild
  - Version tracking and comparison
  - Automatic backup before updates
  - Changelog display on update
  - Rollback capability
  - Component-specific updates (configs, Claude CLI, plugins)

### Changed

**Documentation**
- README.md: Added Method 4 (Dev Container Template), Performance Optimization section
- README.en.md: Same additions in English
- Both READMEs: Template vs Repository approach comparison table

**Template Scripts**
- `src/universal-claude/.devcontainer/init-firewall.sh`: Added ENABLE_FIREWALL check
- `src/universal-claude/.devcontainer/bootstrap-claude.sh`: Added BYPASS_PERMISSIONS support

### Improved

**Performance**
- Container startup time reduced by 70-80% with pre-built images
- Layer caching optimization in Dockerfile
- Multi-architecture builds for better platform compatibility

**Modularity**
- Features can be used independently
- Composable with other Dev Container features
- No dependency on main repository
- Version-pinnable

**Flexibility**
- Template options configurable via VS Code UI
- Feature options via simple JSON configuration
- Works with any base image
- Easy to extend and customize

**Security**
- Automated vulnerability scanning (Trivy)
- SARIF results to GitHub Security tab
- Protected file lists
- Firewall presets for different security levels

## [2.0.0] - 2025-01-11

### Added

**Initial Release**
- Dev Container configuration with Claude Code integration
- Network firewall with domain whitelisting
- Proxy support (HTTP_PROXY, HTTPS_PROXY, ALL_PROXY)
- Multi-method project mounting
- Shell customizations (zsh, persistent history)
- Pre-installed tools (Node.js LTS, Python, GitHub CLI)
- Claude Code configuration with bypass permissions
- Workspace banner showing mount status
- Environment variable configuration
- Security features (protected files, firewall modes)

**Documentation**
- README.md (Chinese) with comprehensive setup guide
- README.en.md (English translation)
- docs/PROXY_SETUP.md (Proxy configuration guide)
- docs/SECURITY.md (Security policy and best practices)
- docs/SECURITY_AUDIT.md (Security audit findings)
- IMPLEMENTATION_PLAN.md (6-phase development roadmap)

**CI/CD**
- `.github/workflows/test-devcontainer.yml` - Container testing
- `.github/workflows/security-scan.yml` - Security scanning
- `.github/workflows/release.yml` - Release automation

**Helper Scripts**
- `scripts/open-project.sh` - Quick project opening
- `scripts/validate-all.sh` - Configuration validation
- `scripts/test-container.sh` - Container testing
- `scripts/security-scan.sh` - Security scanning

### Features

- **Claude Code Integration**: Automatic installation and configuration
- **Bypass Permissions Mode**: Fast development in trusted repos
- **Network Firewall**: Whitelist-based outbound filtering
- **Proxy Support**: Full proxy passthrough
- **Multi-project**: Reusable across all projects
- **Shell Enhancements**: zsh, persistent history, custom banner
- **Pre-installed Plugins**: commit-commands, pr-review-toolkit, security-guidance

---

## Links

- **Repository**: https://github.com/xrf9268-hue/universal-devcontainer
- **Container Registry**: https://github.com/xrf9268-hue/universal-devcontainer/pkgs/container/universal-devcontainer
- **Issue Tracker**: https://github.com/xrf9268-hue/universal-devcontainer/issues
- **Pull Requests**: https://github.com/xrf9268-hue/universal-devcontainer/pulls

---

## Version History

- [2.1.0] - 2025-11-23 - Phase 2 & 3: Modularity and Performance
- [2.0.0] - 2025-01-11 - Initial Release
