#!/usr/bin/env bash
# Check for updates on login (non-interactive, fast)
# This script is sourced by shell rc files

# Only run in interactive shells and only once per session
if [[ -z "${PS1:-}" ]] || [[ -n "${UNIVERSAL_UPDATE_CHECK_DONE:-}" ]]; then
    return 0
fi

export UNIVERSAL_UPDATE_CHECK_DONE=1

# Quick version check (no network calls, just local comparison)
check_updates_quick() {
    local version_file="/universal/.version"
    local last_check_file="/tmp/.universal_last_update_check"
    local check_interval=86400  # 24 hours in seconds

    # Check if we've checked recently
    if [[ -f "$last_check_file" ]]; then
        local last_check
        last_check=$(cat "$last_check_file")
        local now
        now=$(date +%s)
        local diff=$((now - last_check))

        if [[ $diff -lt $check_interval ]]; then
            return 0  # Skip check, too recent
        fi
    fi

    # Only show message if version file exists
    if [[ -f "$version_file" ]]; then
        local current_version
        current_version=$(cat "$version_file")
        echo ""
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "  Universal Dev Container v$current_version"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "  💡 Tip: Check for updates with 'check-updates'"
        echo "      Or update now with 'update-devcontainer'"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo ""
    fi

    # Update last check timestamp
    date +%s > "$last_check_file"
}

# Run quick check (non-blocking)
check_updates_quick 2>/dev/null || true

# Define convenient aliases
alias check-updates='/universal/scripts/update-config.sh --check'
alias update-devcontainer='/universal/scripts/update-config.sh'
alias rollback-devcontainer='/universal/scripts/update-config.sh --rollback'
