#!/bin/bash
# Configure Claude Code Permission Mode
# Allows easy switching between security presets

set -e

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Paths
PRESETS_DIR="${HOME}/.claude/presets"
SETTINGS_FILE="${HOME}/.claude/settings.json"
CURRENT_MODE_FILE="${HOME}/.claude/.current_mode"

# Functions
info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

success() {
    echo -e "${GREEN}[✓]${NC} $1"
}

warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

error() {
    echo -e "${RED}[✗]${NC} $1"
}

show_banner() {
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}  Claude Code Permission Mode Configuration${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo
}

show_current_mode() {
    if [ -f "$CURRENT_MODE_FILE" ]; then
        local mode
        mode=$(cat "$CURRENT_MODE_FILE")
        info "Current mode: ${GREEN}${mode}${NC}"
        echo
    fi
}

show_modes() {
    echo "Available permission modes:"
    echo
    echo -e "${RED}1) ultra-safe${NC} - Maximum Security"
    echo "   ├─ Require approval for ALL operations (including reads)"
    echo "   ├─ Best for: Untrusted repos, security audits"
    echo "   └─ Security: ⚠️⚠️⚠️⚠️⚠️ Maximum"
    echo
    echo -e "${GREEN}2) safe${NC} - Balanced Security (Recommended)"
    echo "   ├─ Allow reads, require approval for writes"
    echo "   ├─ Best for: General development, collaborative work"
    echo "   └─ Security: ⚠️⚠️⚠️ Balanced"
    echo
    echo -e "${YELLOW}3) dev${NC} - Developer Mode"
    echo "   ├─ Bypass permissions for rapid development"
    echo "   ├─ Best for: Personal trusted repos only"
    echo "   └─ Security: ⚠️ Minimal"
    echo
    echo -e "${BLUE}4) review${NC} - Read-Only Mode"
    echo "   ├─ Read and analyze code, no writes allowed"
    echo "   ├─ Best for: Code review, documentation"
    echo "   └─ Security: ⚠️⚠️⚠️⚠️ Read-only"
    echo
    echo -e "5) ${CYAN}custom${NC} - Configure manually"
    echo
}

get_mode_details() {
    local mode=$1
    local preset_file="${PRESETS_DIR}/${mode}.json"

    if [ ! -f "$preset_file" ]; then
        error "Preset file not found: $preset_file"
        return 1
    fi

    echo
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}  ${mode} Mode Details${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo

    # Extract and display details using jq
    if command -v jq &> /dev/null; then
        local description
        local use_cases
        local notes

        description=$(jq -r '.description' "$preset_file")
        echo -e "${BLUE}Description:${NC}"
        echo "  $description"
        echo

        echo -e "${BLUE}Use Cases:${NC}"
        jq -r '.useCases[]' "$preset_file" | while read -r line; do
            echo "  • $line"
        done
        echo

        if jq -e '.warnings' "$preset_file" > /dev/null 2>&1; then
            echo -e "${RED}⚠️  Warnings:${NC}"
            jq -r '.warnings[]' "$preset_file" | while read -r line; do
                echo "  $line"
            done
            echo
        fi

        echo -e "${BLUE}Notes:${NC}"
        jq -r '.notes[]' "$preset_file" | while read -r line; do
            echo "  • $line"
        done
        echo
    else
        warning "jq not installed - showing raw preset"
        cat "$preset_file"
        echo
    fi
}

apply_mode() {
    local mode=$1
    local preset_file="${PRESETS_DIR}/${mode}.json"

    if [ ! -f "$preset_file" ]; then
        error "Preset file not found: $preset_file"
        return 1
    fi

    info "Applying ${mode} mode..."

    # Backup current settings
    if [ -f "$SETTINGS_FILE" ]; then
        cp "$SETTINGS_FILE" "${SETTINGS_FILE}.backup.$(date +%Y%m%d_%H%M%S)"
        success "Current settings backed up"
    fi

    # Apply preset
    # Note: This merges the preset with existing settings
    # For a complete replacement, just copy the preset file
    if command -v jq &> /dev/null; then
        # Merge preset into settings
        local bypass_perms
        bypass_perms=$(jq -r '.bypassPermissions' "$preset_file")

        # Read existing settings or create empty object
        local existing_settings="{}"
        if [ -f "$SETTINGS_FILE" ]; then
            existing_settings=$(cat "$SETTINGS_FILE")
        fi

        # Merge settings
        echo "$existing_settings" | jq --argjson preset "$(cat "$preset_file")" \
            '.bypassPermissions = $preset.bypassPermissions |
             .autoApprove = $preset.autoApprove |
             .alwaysDeny = $preset.alwaysDeny |
             .requireApproval = $preset.requireApproval' \
            > "$SETTINGS_FILE"

        success "Applied ${mode} mode configuration"
    else
        # Fallback: direct copy
        cp "$preset_file" "$SETTINGS_FILE"
        success "Applied ${mode} mode (direct copy)"
    fi

    # Save current mode
    echo "$mode" > "$CURRENT_MODE_FILE"

    echo
    success "✅ Claude Code is now in ${GREEN}${mode}${NC} mode"
    echo
    info "Changes will take effect immediately in Claude Code"
    echo
}

interactive_mode() {
    show_banner
    show_current_mode
    show_modes

    read -p "Select mode [1-5] or [q] to quit: " choice

    case $choice in
        1)
            get_mode_details "ultra-safe"
            read -p "Apply ultra-safe mode? [y/N]: " confirm
            if [[ "$confirm" =~ ^[Yy]$ ]]; then
                apply_mode "ultra-safe"
            fi
            ;;
        2)
            get_mode_details "safe"
            read -p "Apply safe mode? [y/N]: " confirm
            if [[ "$confirm" =~ ^[Yy]$ ]]; then
                apply_mode "safe"
            fi
            ;;
        3)
            get_mode_details "dev"
            warning "Developer mode bypasses all permissions!"
            read -p "Apply dev mode? [y/N]: " confirm
            if [[ "$confirm" =~ ^[Yy]$ ]]; then
                apply_mode "dev"
            fi
            ;;
        4)
            get_mode_details "review"
            read -p "Apply review mode? [y/N]: " confirm
            if [[ "$confirm" =~ ^[Yy]$ ]]; then
                apply_mode "review"
            fi
            ;;
        5)
            info "Opening settings file for manual editing..."
            "${EDITOR:-vim}" "$SETTINGS_FILE"
            success "Manual configuration complete"
            ;;
        q|Q)
            info "Cancelled"
            exit 0
            ;;
        *)
            error "Invalid choice"
            exit 1
            ;;
    esac
}

show_status() {
    show_banner
    if [ -f "$CURRENT_MODE_FILE" ]; then
        local mode
        mode=$(cat "$CURRENT_MODE_FILE")
        success "Current mode: ${GREEN}${mode}${NC}"
        echo
        get_mode_details "$mode"
    else
        info "No mode configured yet"
        echo
    fi
}

# Main script
case "${1:-interactive}" in
    ultra-safe|safe|dev|review)
        apply_mode "$1"
        ;;
    status)
        show_status
        ;;
    list)
        show_banner
        show_modes
        ;;
    interactive|"")
        interactive_mode
        ;;
    help|--help|-h)
        show_banner
        echo "Usage: $(basename "$0") [MODE|COMMAND]"
        echo
        echo "Modes:"
        echo "  ultra-safe    Apply ultra-safe mode (max security)"
        echo "  safe          Apply safe mode (recommended)"
        echo "  dev           Apply dev mode (trusted repos only)"
        echo "  review        Apply review mode (read-only)"
        echo
        echo "Commands:"
        echo "  status        Show current mode"
        echo "  list          List all available modes"
        echo "  interactive   Interactive mode selector (default)"
        echo "  help          Show this help message"
        echo
        echo "Examples:"
        echo "  $(basename "$0")               # Interactive mode"
        echo "  $(basename "$0") safe          # Apply safe mode directly"
        echo "  $(basename "$0") status        # Show current mode"
        echo
        ;;
    *)
        error "Unknown mode or command: $1"
        echo "Run '$(basename "$0") help' for usage"
        exit 1
        ;;
esac
