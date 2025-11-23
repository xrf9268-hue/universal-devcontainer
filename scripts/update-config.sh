#!/usr/bin/env bash
set -euo pipefail

# Universal Dev Container - Incremental Update Script
# Allows updating configurations and tools without rebuilding the container

VERSION_FILE="/universal/.version"
REMOTE_VERSION_URL="https://api.github.com/repos/xrf9268-hue/universal-devcontainer/releases/latest"
REMOTE_REPO="https://github.com/xrf9268-hue/universal-devcontainer.git"
BACKUP_DIR="/universal/.backups"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${BLUE}[INFO]${NC} $*"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $*"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $*"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $*"
}

# Get current version
get_current_version() {
    if [[ -f "$VERSION_FILE" ]]; then
        cat "$VERSION_FILE"
    else
        echo "unknown"
    fi
}

# Get remote version from GitHub
get_remote_version() {
    if command -v curl >/dev/null 2>&1; then
        curl -s "$REMOTE_VERSION_URL" | grep -o '"tag_name": *"[^"]*"' | sed 's/"tag_name": *"\(.*\)"/\1/' || echo "unknown"
    else
        echo "unknown"
    fi
}

# Compare versions
compare_versions() {
    local current="$1"
    local remote="$2"

    if [[ "$current" == "unknown" || "$remote" == "unknown" ]]; then
        return 2  # Cannot compare
    fi

    # Remove 'v' prefix if present
    current="${current#v}"
    remote="${remote#v}"

    if [[ "$current" == "$remote" ]]; then
        return 0  # Same version
    else
        return 1  # Different version
    fi
}

# Show current status
show_status() {
    log_info "Checking for updates..."
    echo ""

    local current_version
    current_version=$(get_current_version)
    local remote_version
    remote_version=$(get_remote_version)

    echo "  Current version: $current_version"
    echo "  Latest version:  $remote_version"
    echo ""

    if compare_versions "$current_version" "$remote_version"; then
        log_success "✓ You are running the latest version"
        return 0
    elif [[ "$remote_version" == "unknown" ]]; then
        log_warning "⚠ Cannot fetch remote version (network issue?)"
        return 1
    else
        log_warning "⚠ Update available: $current_version → $remote_version"
        return 1
    fi
}

# Create backup
create_backup() {
    log_info "Creating backup..."

    local timestamp
    timestamp=$(date +%Y%m%d_%H%M%S)
    local backup_path="$BACKUP_DIR/$timestamp"

    mkdir -p "$backup_path"

    # Backup critical files
    [[ -d /universal/.devcontainer ]] && cp -r /universal/.devcontainer "$backup_path/" || true
    [[ -f /universal/.version ]] && cp /universal/.version "$backup_path/" || true
    [[ -d ~/.claude ]] && cp -r ~/.claude "$backup_path/.claude" || true

    log_success "✓ Backup created: $backup_path"
    echo "$backup_path"
}

# Update scripts and configurations
update_configs() {
    log_info "Updating configurations..."

    # Check if /universal is a git repository
    if [[ -d /universal/.git ]]; then
        cd /universal
        git fetch origin

        local current_branch
        current_branch=$(git rev-parse --abbrev-ref HEAD)
        log_info "Updating from branch: $current_branch"

        git pull origin "$current_branch"
        log_success "✓ Configurations updated"
    else
        log_warning "⚠ /universal is not a git repository"
        log_info "To enable automatic updates, clone the repository:"
        echo "  git clone $REMOTE_REPO /universal"
        return 1
    fi
}

# Update Claude Code CLI
update_claude_cli() {
    log_info "Checking Claude Code CLI..."

    if command -v claude >/dev/null 2>&1; then
        local current_claude
        current_claude=$(claude --version 2>/dev/null | head -1 || echo "unknown")
        echo "  Current: $current_claude"

        read -p "Update Claude Code CLI? [y/N]: " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            npm update -g @anthropic-ai/claude-code
            local new_claude
            new_claude=$(claude --version 2>/dev/null | head -1 || echo "unknown")
            log_success "✓ Claude Code CLI updated: $new_claude"
        else
            log_info "Skipped Claude Code CLI update"
        fi
    else
        log_warning "⚠ Claude Code CLI not installed"
    fi
}

# Update Claude plugins
update_plugins() {
    log_info "Checking Claude Code plugins..."

    if [[ -f ~/.claude/settings.json ]]; then
        local enabled_plugins
        enabled_plugins=$(jq -r '.enabledPlugins | keys[]' ~/.claude/settings.json 2>/dev/null || echo "")

        if [[ -n "$enabled_plugins" ]]; then
            echo "  Enabled plugins:"
            echo "$enabled_plugins" | while read -r plugin; do
                echo "    - $plugin"
            done

            read -p "Update plugins? [y/N]: " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                log_info "Plugin updates require Claude Code marketplace support"
                log_info "Plugins are automatically updated with Claude Code CLI"
            else
                log_info "Skipped plugin update"
            fi
        else
            log_info "No plugins enabled"
        fi
    else
        log_warning "⚠ Claude Code not configured"
    fi
}

# Show changelog
show_changelog() {
    local from_version="$1"
    local to_version="$2"

    log_info "Fetching changelog from $from_version to $to_version..."
    echo ""

    if command -v curl >/dev/null 2>&1 && [[ "$to_version" != "unknown" ]]; then
        local changelog_url="https://api.github.com/repos/xrf9268-hue/universal-devcontainer/releases/tags/$to_version"
        local changelog
        changelog=$(curl -s "$changelog_url" | jq -r '.body' 2>/dev/null || echo "")

        if [[ -n "$changelog" && "$changelog" != "null" ]]; then
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
            echo "  CHANGELOG: $to_version"
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
            echo "$changelog"
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
            echo ""
        else
            log_warning "⚠ Changelog not available"
        fi
    else
        log_warning "⚠ Cannot fetch changelog (curl not available or version unknown)"
    fi
}

# Rollback to backup
rollback() {
    log_info "Available backups:"
    echo ""

    if [[ ! -d "$BACKUP_DIR" ]] || [[ -z "$(ls -A "$BACKUP_DIR" 2>/dev/null)" ]]; then
        log_warning "⚠ No backups found"
        return 1
    fi

    local backups
    mapfile -t backups < <(ls -1t "$BACKUP_DIR")
    local i=1
    for backup in "${backups[@]}"; do
        echo "  $i) $backup"
        ((i++))
    done
    echo ""

    read -p "Select backup to restore [1-${#backups[@]}] or [q]uit: " choice

    if [[ "$choice" == "q" ]]; then
        log_info "Rollback cancelled"
        return 0
    fi

    if [[ "$choice" =~ ^[0-9]+$ ]] && [[ "$choice" -ge 1 ]] && [[ "$choice" -le "${#backups[@]}" ]]; then
        local backup_path="$BACKUP_DIR/${backups[$((choice-1))]}"
        log_info "Restoring from: $backup_path"

        # Restore files
        [[ -d "$backup_path/.devcontainer" ]] && cp -r "$backup_path/.devcontainer" /universal/ || true
        [[ -f "$backup_path/.version" ]] && cp "$backup_path/.version" /universal/ || true
        [[ -d "$backup_path/.claude" ]] && cp -r "$backup_path/.claude" ~/ || true

        log_success "✓ Rollback completed"
    else
        log_error "Invalid selection"
        return 1
    fi
}

# Main update flow
do_update() {
    local current_version
    current_version=$(get_current_version)
    local remote_version
    remote_version=$(get_remote_version)

    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  Universal Dev Container - Update Manager"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""

    show_status || true

    if compare_versions "$current_version" "$remote_version"; then
        return 0
    fi

    echo ""
    read -p "Proceed with update? [y/N]: " -n 1 -r
    echo

    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log_info "Update cancelled"
        return 0
    fi

    # Create backup before updating
    local backup_path
    backup_path=$(create_backup)

    # Update components
    update_configs || log_warning "⚠ Config update failed"
    update_claude_cli || true
    update_plugins || true

    # Update version file
    echo "$remote_version" > "$VERSION_FILE"

    # Show changelog
    show_changelog "$current_version" "$remote_version"

    echo ""
    log_success "✓ Update completed successfully!"
    echo ""
    echo "Backup location: $backup_path"
    echo "To rollback: $0 --rollback"
    echo ""
    log_warning "⚠ Note: Some changes may require container restart"
    echo ""
}

# Parse command line arguments
case "${1:-}" in
    --check|-c)
        show_status
        ;;
    --rollback|-r)
        rollback
        ;;
    --help|-h)
        cat <<EOF
Universal Dev Container - Update Manager

Usage: $0 [OPTIONS]

Options:
  --check, -c        Check for updates without applying
  --rollback, -r     Rollback to a previous backup
  --help, -h         Show this help message
  (no option)        Check and apply updates

Examples:
  $0                 # Check and apply updates
  $0 --check         # Check for updates only
  $0 --rollback      # Rollback to previous version

EOF
        ;;
    *)
        do_update
        ;;
esac
