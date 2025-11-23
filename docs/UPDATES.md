# Update Guide

This guide explains how to update your Universal Dev Container without rebuilding.

## Quick Start

```bash
# Check for updates
check-updates

# Apply updates
update-devcontainer

# Rollback if needed
rollback-devcontainer
```

## Update Mechanism

Starting from v2.1.0, you can update configurations, scripts, and tools **without rebuilding** the container.

### What Gets Updated

- ✅ Configuration files (`.devcontainer/*`)
- ✅ Scripts (`scripts/*`)
- ✅ Claude Code CLI (optional)
- ✅ Claude Code plugins (optional)
- ✅ Documentation
- ✅ Version tracking

### What Doesn't Get Updated

- ❌ Base system packages (requires rebuild)
- ❌ Dev Container Features (requires rebuild)
- ❌ Container image itself (use pre-built image instead)

## Commands

### Check for Updates

```bash
check-updates
# or
/universal/scripts/update-config.sh --check
```

**Output**:
```
[INFO] Checking for updates...

  Current version: v2.1.0
  Latest version:  v2.2.0

⚠ Update available: v2.1.0 → v2.2.0
```

### Apply Updates

```bash
update-devcontainer
# or
/universal/scripts/update-config.sh
```

**Interactive prompts**:
1. Confirm update
2. Choose to update Claude CLI (optional)
3. Choose to update plugins (optional)

**What happens**:
1. Creates automatic backup
2. Updates configurations via git pull
3. Updates Claude CLI (if confirmed)
4. Updates version file
5. Shows changelog
6. Reports completion with backup location

### Rollback to Previous Version

```bash
rollback-devcontainer
# or
/universal/scripts/update-config.sh --rollback
```

**Interactive selection**:
```
Available backups:

  1) 20251123_120530
  2) 20251120_093045
  3) 20251118_161522

Select backup to restore [1-3] or [q]uit:
```

## Update Scenarios

### Scenario 1: Configuration-Only Update

**When**: New features in scripts, firewall rules, or Claude settings

**Steps**:
1. Run `update-devcontainer`
2. Confirm update
3. Skip Claude CLI update
4. No container restart needed

**Time**: ~10 seconds

### Scenario 2: Claude CLI Update

**When**: New Claude Code version available

**Steps**:
1. Run `update-devcontainer`
2. Confirm update
3. Confirm Claude CLI update
4. Plugins auto-update with CLI

**Time**: ~1-2 minutes

### Scenario 3: Major Version Update

**When**: Breaking changes or new base image

**Steps**:
1. Check changelog: `update-devcontainer` (shows changelog before update)
2. Create manual backup if needed
3. Apply update
4. Test in container
5. Rollback if issues: `rollback-devcontainer`

**Time**: ~2-3 minutes

## Automatic Update Checks

On every new terminal session, you'll see:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Universal Dev Container v2.1.0
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  💡 Tip: Check for updates with 'check-updates'
      Or update now with 'update-devcontainer'
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**Frequency**: Once per day (24-hour cooldown)

**To disable**: Add to your `~/.bashrc` or `~/.zshrc`:
```bash
export UNIVERSAL_UPDATE_CHECK_DONE=1
```

## Backups

### Automatic Backups

Created automatically before every update:

**Location**: `/universal/.backups/YYYYMMDD_HHMMSS/`

**Contains**:
- `.devcontainer/` directory
- `.version` file
- `~/.claude/` directory (if exists)

**Retention**: Manual cleanup (no automatic deletion)

### Manual Backups

```bash
# Create backup before risky changes
mkdir -p /universal/.backups/manual_$(date +%Y%m%d_%H%M%S)
cp -r /universal/.devcontainer /universal/.backups/manual_$(date +%Y%m%d_%H%M%S)/
```

### Cleanup Old Backups

```bash
# List backups
ls -lh /universal/.backups/

# Remove old backups (keep last 5)
cd /universal/.backups && ls -1t | tail -n +6 | xargs rm -rf
```

## Version Tracking

### Check Current Version

```bash
cat /universal/.version
```

### Version File Location

- **Container**: `/universal/.version`
- **Format**: `vX.Y.Z` (semantic versioning)

### Manual Version Update

```bash
echo "v2.1.0" > /universal/.version
```

## Troubleshooting

### "Cannot fetch remote version"

**Cause**: Network issue or GitHub API rate limit

**Solution**:
1. Check internet connection
2. Try again later (rate limit: 60 requests/hour)
3. Update manually:
   ```bash
   cd /universal && git pull
   ```

### "/universal is not a git repository"

**Cause**: Container started without git clone

**Solution**:
1. Clone repository:
   ```bash
   cd /tmp
   git clone https://github.com/xrf9268-hue/universal-devcontainer.git
   sudo cp -r universal-devcontainer/* /universal/
   ```

2. Or use pre-built image (already includes configs)

### "Update failed" after applying

**Solution**: Rollback
```bash
rollback-devcontainer
```

Select most recent backup and restore.

### Changes not taking effect

**Some changes require container restart**:

```bash
# In VS Code
Cmd/Ctrl + Shift + P → "Dev Containers: Rebuild Container"
```

**Or**:
```bash
# Stop and start container
exit  # exit container
# Reopen in VS Code
```

## Best Practices

### Before Updating

1. ✅ Check changelog: `update-devcontainer` (shown before applying)
2. ✅ Commit your work: `git commit -am "WIP before update"`
3. ✅ Note current version: `cat /universal/.version`

### After Updating

1. ✅ Test critical workflows
2. ✅ Check Claude Code: `claude --version`
3. ✅ Verify configurations work
4. ✅ Keep backup for 1-2 days before cleanup

### Update Frequency

- **Stable environment**: Monthly or on new releases
- **Development environment**: Weekly or as needed
- **Critical fixes**: Immediately

## Changelog

View full changelog:
- **Online**: https://github.com/xrf9268-hue/universal-devcontainer/blob/main/CHANGELOG.md
- **Local**: `cat /universal/CHANGELOG.md`
- **On update**: Automatically displayed

## Migration from Old Versions

### From v2.0.0 to v2.1.0

**New features**:
- Incremental updates (this guide!)
- Pre-built images
- Dev Container Template
- Claude Code and Firewall Features

**Breaking changes**: None

**Steps**:
1. Run `update-devcontainer`
2. Enjoy new features

### From Dockerfile to Pre-built Image

**Optional migration** for faster startup:

**Before** (build from Dockerfile):
```json
{
  "build": { "dockerfile": "Dockerfile" }
}
```

**After** (use pre-built image):
```json
{
  "image": "ghcr.io/xrf9268-hue/universal-devcontainer:latest"
}
```

**Benefit**: 70% faster startup

## Related Documentation

- [CHANGELOG.md](../CHANGELOG.md) - Full version history
- [README.md](../README.md) - Main documentation
- [IMPLEMENTATION_PLAN.md](../IMPLEMENTATION_PLAN.md) - Development roadmap
- [Pre-built Image Guide](../examples/prebuilt-image/README.md) - Using pre-built images

## Support

- **Issues**: https://github.com/xrf9268-hue/universal-devcontainer/issues
- **Discussions**: https://github.com/xrf9268-hue/universal-devcontainer/discussions
- **Email**: Create an issue on GitHub

---

**Last Updated**: 2025-11-23
**Version**: 2.1.0
