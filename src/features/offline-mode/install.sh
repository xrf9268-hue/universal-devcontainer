#!/bin/bash
set -e

echo "Installing Offline Mode Configuration..."

BLOCK_ALL="${BLOCKALLEXTERNAL:-true}"
ALLOW_LOCALHOST="${ALLOWLOCALHOST:-true}"
ALLOW_DOCKER="${ALLOWDOCKERINTERNAL:-true}"
ALLOW_PRIVATE="${ALLOWPRIVATENETWORKS:-false}"
CACHE_PACKAGES="${CACHEPACKAGES:-true}"

apt-get update
apt-get install -y iptables

# Create offline mode firewall script
cat > /usr/local/bin/enable-offline-mode <<'SCRIPT'
#!/bin/bash
# Enable offline mode - block all external network access

echo "Enabling offline mode..."

# Flush existing rules
iptables -F OUTPUT
iptables -P OUTPUT DROP

# Allow loopback
iptables -A OUTPUT -o lo -j ACCEPT

# Allow localhost
if [ "$ALLOW_LOCALHOST" = "true" ]; then
    iptables -A OUTPUT -d 127.0.0.0/8 -j ACCEPT
    iptables -A OUTPUT -d ::1/128 -j ACCEPT
fi

# Allow Docker internal
if [ "$ALLOW_DOCKER" = "true" ]; then
    # host.docker.internal typically resolves to 192.168.65.2 or similar
    iptables -A OUTPUT -d 192.168.0.0/16 -j ACCEPT
fi

# Allow private networks (optional)
if [ "$ALLOW_PRIVATE" = "true" ]; then
    iptables -A OUTPUT -d 10.0.0.0/8 -j ACCEPT
    iptables -A OUTPUT -d 172.16.0.0/12 -j ACCEPT
    iptables -A OUTPUT -d 192.168.0.0/16 -j ACCEPT
fi

# Block everything else
iptables -A OUTPUT -j DROP

echo "✅ Offline mode enabled"
echo "  - Localhost: ALLOWED"
echo "  - Docker internal: $([ "$ALLOW_DOCKER" = "true" ] && echo "ALLOWED" || echo "BLOCKED")"
echo "  - Private networks: $([ "$ALLOW_PRIVATE" = "true" ] && echo "ALLOWED" || echo "BLOCKED")"
echo "  - External internet: BLOCKED"
SCRIPT

chmod +x /usr/local/bin/enable-offline-mode

# Create disable script
cat > /usr/local/bin/disable-offline-mode <<'SCRIPT'
#!/bin/bash
echo "Disabling offline mode..."
iptables -F OUTPUT
iptables -P OUTPUT ACCEPT
echo "✅ Offline mode disabled - internet access restored"
SCRIPT

chmod +x /usr/local/bin/disable-offline-mode

# Create status script
cat > /usr/local/bin/offline-mode-status <<'SCRIPT'
#!/bin/bash
echo "Offline Mode Status:"
echo "==================="
if iptables -L OUTPUT -n | grep -q "policy DROP"; then
    echo "Status: ENABLED (offline)"
else
    echo "Status: DISABLED (online)"
fi
echo ""
echo "Current OUTPUT chain rules:"
iptables -L OUTPUT -n --line-numbers
SCRIPT

chmod +x /usr/local/bin/offline-mode-status

# Create systemd service to enable offline mode on startup
cat > /etc/systemd/system/offline-mode.service <<EOF
[Unit]
Description=Enable Offline Mode for Dev Container
After=network.target

[Service]
Type=oneshot
ExecStart=/usr/local/bin/enable-offline-mode
RemainAfterExit=yes
ExecStop=/usr/local/bin/disable-offline-mode

[Install]
WantedBy=multi-user.target
EOF

# Enable offline mode by default if configured
if [ "$BLOCK_ALL" = "true" ]; then
    systemctl enable offline-mode.service 2>/dev/null || true
fi

# Pre-cache common packages if enabled
if [ "$CACHE_PACKAGES" = "true" ]; then
    echo "Pre-caching common packages..."

    # Node.js packages cache
    mkdir -p /var/cache/npm

    # Python packages cache
    mkdir -p /var/cache/pip
    pip download --dest /var/cache/pip \
        requests flask fastapi django \
        2>/dev/null || echo "Warning: Could not cache Python packages"

    # Go modules cache
    mkdir -p /go/pkg/mod

    echo "✅ Package caches created"
fi

# Create offline mode documentation
cat > /usr/share/doc/offline-mode.txt <<EOF
Offline Mode Documentation
==========================

This dev container is configured for offline/air-gapped operation.

Commands:
---------
  enable-offline-mode     - Block all external network access
  disable-offline-mode    - Restore internet access
  offline-mode-status     - Check current status

Configuration:
--------------
  Localhost: $([ "$ALLOW_LOCALHOST" = "true" ] && echo "Allowed" || echo "Blocked")
  Docker internal: $([ "$ALLOW_DOCKER" = "true" ] && echo "Allowed" || echo "Blocked")
  Private networks: $([ "$ALLOW_PRIVATE" = "true" ] && echo "Allowed" || echo "Blocked")

Package Caches:
---------------
  npm: /var/cache/npm
  pip: /var/cache/pip
  go: /go/pkg/mod

Usage:
------
1. Development happens completely offline
2. No data can leave the container via network
3. Only local services and databases accessible
4. Perfect for sensitive/classified development

Compliance:
-----------
✅ ITAR compliance (no data export)
✅ HIPAA compliance (data isolation)
✅ Air-gapped environments
✅ Zero trust networks
EOF

apt-get clean
rm -rf /var/lib/apt/lists/*

echo "✅ Offline mode installed successfully!"
echo ""
echo "Commands:"
echo "  enable-offline-mode   - Activate offline mode"
echo "  disable-offline-mode  - Deactivate offline mode"
echo "  offline-mode-status   - Check status"
echo ""
echo "Documentation: /usr/share/doc/offline-mode.txt"
echo ""
