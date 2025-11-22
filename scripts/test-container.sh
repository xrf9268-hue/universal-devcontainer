#!/bin/bash
# scripts/test-container.sh
# Test container build and functionality

set -e

echo "🚀 Testing universal-devcontainer..."
echo ""

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check prerequisites
echo "📋 Checking prerequisites..."

if ! command -v docker &> /dev/null; then
  echo -e "${RED}✗ Docker not found${NC}"
  exit 1
fi
echo -e "${GREEN}✓ Docker installed${NC}"

if ! command -v devcontainer &> /dev/null; then
  echo -e "${YELLOW}⚠ devcontainer CLI not found${NC}"
  echo "  Install with: npm install -g @devcontainers/cli"
  echo "  Falling back to docker-based testing..."
  USE_DOCKER=1
else
  echo -e "${GREEN}✓ devcontainer CLI installed${NC}"
  USE_DOCKER=0
fi
echo ""

# Set test environment
export PROJECT_PATH="${PROJECT_PATH:-$PWD}"
echo "📂 Using PROJECT_PATH: $PROJECT_PATH"
echo ""

# Test container build
echo "🏗️  Building container..."
if [ $USE_DOCKER -eq 1 ]; then
  # Docker-based build
  docker build -t universal-devcontainer:test -f .devcontainer/Dockerfile .devcontainer/
  echo -e "${GREEN}✓ Container built successfully${NC}"
else
  # devcontainer CLI build
  devcontainer build --workspace-folder .
  echo -e "${GREEN}✓ Container built successfully${NC}"
fi
echo ""

# Test container tools (if devcontainer CLI available)
if [ $USE_DOCKER -eq 0 ]; then
  echo "🔧 Testing installed tools..."

  # Test Node.js
  if devcontainer exec --workspace-folder . node --version > /dev/null 2>&1; then
    NODE_VERSION=$(devcontainer exec --workspace-folder . node --version)
    echo -e "${GREEN}✓ Node.js: $NODE_VERSION${NC}"
  else
    echo -e "${RED}✗ Node.js not available${NC}"
  fi

  # Test Python
  if devcontainer exec --workspace-folder . python3 --version > /dev/null 2>&1; then
    PYTHON_VERSION=$(devcontainer exec --workspace-folder . python3 --version)
    echo -e "${GREEN}✓ Python: $PYTHON_VERSION${NC}"
  else
    echo -e "${RED}✗ Python not available${NC}"
  fi

  # Test GitHub CLI
  if devcontainer exec --workspace-folder . gh --version > /dev/null 2>&1; then
    GH_VERSION=$(devcontainer exec --workspace-folder . gh --version | head -n1)
    echo -e "${GREEN}✓ GitHub CLI: $GH_VERSION${NC}"
  else
    echo -e "${RED}✗ GitHub CLI not available${NC}"
  fi

  # Test Claude CLI
  if devcontainer exec --workspace-folder . which claude > /dev/null 2>&1; then
    echo -e "${GREEN}✓ Claude CLI installed${NC}"
  else
    echo -e "${YELLOW}⚠ Claude CLI not found (may need bootstrap)${NC}"
  fi

  echo ""
fi

# Test configuration files
echo "📝 Testing configuration generation..."
if [ -f .devcontainer/devcontainer.json ]; then
  echo -e "${GREEN}✓ devcontainer.json exists${NC}"
else
  echo -e "${RED}✗ devcontainer.json missing${NC}"
fi

if [ -f .claude/settings.local.json ]; then
  echo -e "${GREEN}✓ Claude settings exist${NC}"
else
  echo -e "${YELLOW}⚠ Claude settings not found (will be generated on first run)${NC}"
fi
echo ""

# Summary
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${GREEN}✅ Container tests completed!${NC}"
echo ""
echo "To open the container in VS Code:"
echo "  ./scripts/open-project.sh ."
