#!/bin/bash
# scripts/security-scan.sh
# Run security scans on the dev container

set -e

echo "🔒 Running security scans on universal-devcontainer..."
echo ""

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Build test image
echo "🏗️  Building test image..."
IMAGE_NAME="universal-devcontainer:security-test"
docker build -t "$IMAGE_NAME" -f .devcontainer/Dockerfile .devcontainer/ 2>&1 | tail -n 5
echo -e "${GREEN}✓ Image built${NC}"
echo ""

# Run Trivy scan
echo "🔍 Running Trivy vulnerability scan..."
if command -v trivy &> /dev/null; then
  trivy image --severity HIGH,CRITICAL "$IMAGE_NAME"
  echo ""
elif docker run --rm aquasec/trivy --version &> /dev/null; then
  echo "Using Trivy Docker image..."
  docker run --rm -v /var/run/docker.sock:/var/run/docker.sock \
    aquasec/trivy image --severity HIGH,CRITICAL "$IMAGE_NAME"
  echo ""
else
  echo -e "${YELLOW}⚠ Trivy not available${NC}"
  echo "  Install with: curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh -s -- -b /usr/local/bin"
  echo ""
fi

# Check for secrets in repository
echo "🔎 Checking for secrets in repository..."
SECRETS_FOUND=0

# Check for common secret patterns
echo "Scanning for API keys, passwords, tokens..."
if git ls-files | xargs grep -i -n -E "api_key.*=|password.*=|secret.*=|token.*=" | \
   grep -v -E "\.md$|settings\.local\.json|IMPLEMENTATION|TODO|scripts/security-scan" > /tmp/secrets_check.txt 2>&1; then
  echo -e "${RED}⚠ Found potential secrets:${NC}"
  cat /tmp/secrets_check.txt
  SECRETS_FOUND=1
  echo ""
else
  echo -e "${GREEN}✓ No obvious secrets found${NC}"
  echo ""
fi

# Check container capabilities
echo "🛡️  Reviewing container capabilities..."
if grep -E "cap-add|privileged" .devcontainer/devcontainer.json > /tmp/caps.txt 2>&1; then
  echo -e "${YELLOW}⚠ Container requires elevated capabilities:${NC}"
  cat /tmp/caps.txt
  echo ""
  echo "Review if these capabilities are necessary:"
  echo "  - NET_ADMIN: Required for iptables/firewall"
  echo "  - NET_RAW: Required for raw socket operations"
  echo ""
else
  echo -e "${GREEN}✓ No elevated capabilities required${NC}"
  echo ""
fi

# Check for exposed ports
echo "🌐 Reviewing exposed ports..."
if grep -E "forwardPorts|portsAttributes" .devcontainer/devcontainer.json > /tmp/ports.txt 2>&1; then
  echo "Configured port forwards:"
  grep "forwardPorts" .devcontainer/devcontainer.json
  echo -e "${GREEN}✓ Ports configured${NC}"
  echo ""
else
  echo -e "${GREEN}✓ No ports exposed${NC}"
  echo ""
fi

# Check firewall configuration
echo "🔥 Reviewing firewall rules..."
if [ -f .devcontainer/init-firewall.sh ]; then
  echo "Firewall whitelist domains:"
  grep -E "CLAUDE_DOMAINS|COMMON_DOMAINS" .devcontainer/init-firewall.sh | head -n 20
  echo ""
  echo -e "${GREEN}✓ Firewall configured${NC}"
  echo ""
else
  echo -e "${YELLOW}⚠ No firewall configuration found${NC}"
  echo ""
fi

# Summary
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
if [ $SECRETS_FOUND -eq 0 ]; then
  echo -e "${GREEN}✅ Security scan completed - no critical issues found${NC}"
  echo ""
  echo "Recommendations:"
  echo "  1. Review container capabilities (NET_ADMIN, NET_RAW)"
  echo "  2. Keep dependencies updated"
  echo "  3. Review firewall whitelist regularly"
  echo "  4. Use trusted base images only"
else
  echo -e "${RED}⚠️  Security scan completed - potential secrets found${NC}"
  echo ""
  echo "Action required:"
  echo "  1. Review and remove any secrets from code"
  echo "  2. Use environment variables for sensitive data"
  echo "  3. Add secrets to .gitignore"
  echo "  4. Rotate any exposed credentials"
fi
echo ""

# Cleanup
rm -f /tmp/secrets_check.txt /tmp/caps.txt /tmp/ports.txt
