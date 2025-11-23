#!/bin/bash
# Project Template Generator
# Creates new projects from Universal Dev Container templates

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"
TEMPLATES_DIR="$REPO_ROOT/examples"

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
    echo -e "${CYAN}  Universal Dev Container - Project Generator${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo
}

show_templates() {
    echo "Available project templates:"
    echo
    echo -e "${GREEN}Frontend:${NC}"
    echo "  1) react-ts       - React 18 + TypeScript + Vite"
    echo "  2) nextjs         - Next.js 15 + App Router + TypeScript"
    echo
    echo -e "${GREEN}Backend:${NC}"
    echo "  3) express-ts     - Express 4 + TypeScript + Node.js"
    echo "  4) fastapi        - FastAPI + Python 3.12"
    echo "  5) django         - Django 5.0 + Python 3.12"
    echo "  6) go-gin         - Go 1.21 + Gin framework"
    echo
    echo -e "${GREEN}Full-Stack:${NC}"
    echo "  7) fullstack      - React + FastAPI + PostgreSQL + Redis"
    echo
    echo -e "${GREEN}Advanced:${NC}"
    echo "  8) microservices  - Multi-service architecture"
    echo
}

get_template_path() {
    local template=$1
    case "$template" in
        react-ts|1)
            echo "$TEMPLATES_DIR/react-app"
            ;;
        nextjs|2)
            echo "$TEMPLATES_DIR/nextjs-app"
            ;;
        express-ts|3)
            echo "$TEMPLATES_DIR/nodejs-express"
            ;;
        fastapi|4)
            echo "$TEMPLATES_DIR/python-fastapi"
            ;;
        django|5)
            echo "$TEMPLATES_DIR/python-django"
            ;;
        go-gin|6)
            echo "$TEMPLATES_DIR/go-app"
            ;;
        fullstack|7)
            echo "$TEMPLATES_DIR/multi-container/fullstack"
            ;;
        microservices|8)
            echo "$TEMPLATES_DIR/multi-container/microservices"
            ;;
        *)
            echo ""
            ;;
    esac
}

create_project() {
    local project_name=$1
    local template=$2
    local template_path

    template_path=$(get_template_path "$template")

    if [ -z "$template_path" ]; then
        error "Invalid template: $template"
        return 1
    fi

    if [ ! -d "$template_path" ]; then
        error "Template not found: $template_path"
        return 1
    fi

    if [ -d "$project_name" ]; then
        error "Directory already exists: $project_name"
        return 1
    fi

    info "Creating project: $project_name"
    info "Using template: $template"

    # Create project directory
    mkdir -p "$project_name"

    # Copy template files
    info "Copying template files..."
    cp -r "$template_path"/* "$project_name/" 2>/dev/null || true
    cp -r "$template_path"/.* "$project_name/" 2>/dev/null || true

    # Update project name in files
    if [ -f "$project_name/package.json" ]; then
        sed -i.bak "s/\"name\": \"[^\"]*\"/\"name\": \"$project_name\"/" "$project_name/package.json"
        rm -f "$project_name/package.json.bak"
    fi

    # Initialize git
    cd "$project_name"
    if [ ! -d ".git" ]; then
        git init
        git add .
        git commit -m "Initial commit from universal-devcontainer template" 2>/dev/null || true
    fi
    cd ..

    success "✅ Project created successfully!"
    echo
    echo "Next steps:"
    echo "  1. cd $project_name"
    echo "  2. code ."
    echo "  3. Reopen in Container"
    echo
}

interactive_mode() {
    show_banner
    show_templates

    read -p "Select template [1-8]: " template_choice
    read -p "Project name: " project_name

    if [ -z "$project_name" ]; then
        error "Project name cannot be empty"
        exit 1
    fi

    # Confirm
    echo
    info "Creating project with the following settings:"
    echo "  Name: $project_name"
    echo "  Template: $template_choice"
    echo
    read -p "Continue? [Y/n]: " confirm

    if [[ "$confirm" =~ ^[Nn]$ ]]; then
        info "Cancelled"
        exit 0
    fi

    create_project "$project_name" "$template_choice"
}

# Main script
case "${1:-interactive}" in
    interactive|"")
        interactive_mode
        ;;
    help|--help|-h)
        show_banner
        echo "Usage: $(basename "$0") [PROJECT_NAME] [TEMPLATE]"
        echo
        echo "Templates:"
        show_templates
        echo
        echo "Examples:"
        echo "  $(basename "$0")                     # Interactive mode"
        echo "  $(basename "$0") my-app react-ts     # Create React app"
        echo "  $(basename "$0") my-api fastapi      # Create FastAPI"
        echo "  $(basename "$0") my-stack fullstack  # Create full-stack"
        echo
        ;;
    *)
        if [ -z "$2" ]; then
            error "Usage: $(basename "$0") PROJECT_NAME TEMPLATE"
            echo "Run '$(basename "$0") help' for more information"
            exit 1
        fi
        create_project "$1" "$2"
        ;;
esac
