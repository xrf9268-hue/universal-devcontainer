#!/usr/bin/env bash
set -euo pipefail

# Feature options (automatically uppercased by Dev Container CLI)
PRESET="${PRESET:-standard}"
WHITELIST_DOMAINS="${WHITELISTDOMAINS:-}"
STRICT_PROXY="${STRICTPROXYMODE:-false}"
ALLOW_SSH="${ALLOWSSH:-github-only}"

echo "[firewall-feature] Installing firewall with preset: $PRESET"

# Install required packages
apt-get update
apt-get install -y iptables dnsutils
apt-get clean
rm -rf /var/lib/apt/lists/*

# Define domain sets for presets
STANDARD_DOMAINS=(
  "registry.npmjs.org"
  "npmjs.org"
  "github.com"
  "api.github.com"
  "objects.githubusercontent.com"
  "raw.githubusercontent.com"
  "claude.ai"
  "api.anthropic.com"
  "console.anthropic.com"
  "pypi.org"
  "files.pythonhosted.org"
)

STRICT_DOMAINS=(
  "registry.npmjs.org"
  "github.com"
  "api.anthropic.com"
)

PERMISSIVE_DOMAINS=(
  "${STANDARD_DOMAINS[@]}"
  "docker.io"
  "gcr.io"
  "quay.io"
  "hub.docker.com"
  "golang.org"
  "proxy.golang.org"
  "storage.googleapis.com"
)

# Select domain list based on preset
case "$PRESET" in
  strict)
    DOMAINS=("${STRICT_DOMAINS[@]}")
    ;;
  permissive)
    DOMAINS=("${PERMISSIVE_DOMAINS[@]}")
    ;;
  *)
    DOMAINS=("${STANDARD_DOMAINS[@]}")
    ;;
esac

# Add custom whitelist domains
if [[ -n "$WHITELIST_DOMAINS" ]]; then
  echo "[firewall-feature] Adding custom domains: $WHITELIST_DOMAINS"
  IFS=',' read -ra CUSTOM_ARRAY <<< "$WHITELIST_DOMAINS"
  DOMAINS+=("${CUSTOM_ARRAY[@]}")
fi

# Convert domain array to space-separated string for the script
DOMAIN_LIST="${DOMAINS[*]}"

# Create the firewall initialization script
cat > /usr/local/bin/init-firewall.sh <<'FIREWALL_SCRIPT'
#!/usr/bin/env bash
set -euo pipefail

# Check if iptables is available
command -v iptables >/dev/null 2>&1 || { echo "[firewall] iptables not found; skipping."; exit 0; }
if ! iptables -L OUTPUT >/dev/null 2>&1; then
  echo "[firewall] No permission to manage iptables. Did you set --cap-add=NET_ADMIN? Skipping."
  exit 0
fi

# Domain whitelist (populated by install script)
ALLOW_DOMAINS=(%DOMAIN_LIST%)

# Settings (populated by install script)
STRICT_PROXY_MODE=%STRICT_PROXY%
ALLOW_SSH_MODE=%ALLOW_SSH%

if [[ "$STRICT_PROXY_MODE" = "true" ]]; then
  echo "[firewall] Applying egress firewall (STRICT proxy-only mode)"
  echo "[firewall] All direct HTTPS/SSH will be blocked - traffic must use HTTP_PROXY"
else
  echo "[firewall] Applying egress firewall (default deny mode)"
  echo "[firewall] Whitelisted domains: ${ALLOW_DOMAINS[*]}"
fi

# Reset OUTPUT chain
iptables -P OUTPUT ACCEPT
iptables -F OUTPUT

# Allow loopback
iptables -A OUTPUT -o lo -j ACCEPT

# Allow established connections
iptables -A OUTPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

# Allow DNS
for ns in $(awk '/^nameserver/{print $2}' /etc/resolv.conf | tr -d '[]'); do
  iptables -A OUTPUT -p udp -d "$ns" --dport 53 -j ACCEPT || true
  iptables -A OUTPUT -p tcp -d "$ns" --dport 53 -j ACCEPT || true
done

# Helper function to resolve IPs
resolve_ips() {
  local host="$1"
  getent ahostsv4 "$host" 2>/dev/null | awk '{print $1}' | sort -u
}

# Allow proxy connections
allow_proxy() {
  PROXY_RAW="${HTTP_PROXY:-${HTTPS_PROXY:-${ALL_PROXY:-}}}"
  [ -z "$PROXY_RAW" ] && return 0

  # Parse proxy URL
  hp="${PROXY_RAW#*://}"
  hp="${hp%%/*}"
  hp="${hp#*@}"

  # Extract host and port
  if [[ "$hp" =~ ^\[([0-9a-fA-F:]+)\]:(.+)$ ]]; then
    PROXY_HOST="${BASH_REMATCH[1]}"
    PROXY_PORT="${BASH_REMATCH[2]}"
  elif [[ "$hp" =~ ^([^:]+):([0-9]+)$ ]]; then
    PROXY_HOST="${BASH_REMATCH[1]}"
    PROXY_PORT="${BASH_REMATCH[2]}"
  else
    return 0
  fi

  [ -z "$PROXY_HOST" ] || [ -z "$PROXY_PORT" ] && return 0

  echo "[firewall] Allowing proxy: $PROXY_HOST:$PROXY_PORT"
  for ip in $(resolve_ips "$PROXY_HOST"); do
    iptables -A OUTPUT -p tcp -d "$ip" --dport "$PROXY_PORT" -j ACCEPT || true
  done
}

allow_proxy

# If not in strict proxy mode, allow direct HTTPS/SSH to whitelisted domains
if [[ "$STRICT_PROXY_MODE" != "true" ]]; then
  # Allow HTTPS to whitelisted domains
  for host in "${ALLOW_DOMAINS[@]}"; do
    for ip in $(resolve_ips "$host"); do
      iptables -A OUTPUT -p tcp -d "$ip" --dport 443 -j ACCEPT || true
    done
  done

  # SSH handling
  case "$ALLOW_SSH_MODE" in
    all)
      echo "[firewall] Allowing SSH to all destinations"
      iptables -A OUTPUT -p tcp --dport 22 -j ACCEPT
      ;;
    github-only)
      echo "[firewall] Allowing SSH to GitHub only"
      for ip in $(resolve_ips "github.com"); do
        iptables -A OUTPUT -p tcp -d "$ip" --dport 22 -j ACCEPT || true
      done
      ;;
    none)
      echo "[firewall] Blocking all SSH"
      ;;
  esac
else
  echo "[firewall] STRICT_PROXY_MODE: Skipping direct HTTPS/SSH rules"
fi

# Set default policy to DROP
iptables -P OUTPUT DROP

echo "[firewall] ✅ Firewall rules applied"
iptables -S OUTPUT | head -20 || true
FIREWALL_SCRIPT

# Replace placeholders in the script
sed -i "s|%DOMAIN_LIST%|$DOMAIN_LIST|g" /usr/local/bin/init-firewall.sh
sed -i "s|%STRICT_PROXY%|$STRICT_PROXY|g" /usr/local/bin/init-firewall.sh
sed -i "s|%ALLOW_SSH%|$ALLOW_SSH|g" /usr/local/bin/init-firewall.sh

# Make script executable
chmod +x /usr/local/bin/init-firewall.sh

echo "[firewall-feature] ✅ Installation complete!"
echo "  - Preset: $PRESET"
echo "  - Strict proxy mode: $STRICT_PROXY"
echo "  - SSH access: $ALLOW_SSH"
echo "  - Whitelisted domains: ${#DOMAINS[@]} total"
[[ -n "$WHITELIST_DOMAINS" ]] && echo "  - Custom domains: $WHITELIST_DOMAINS"

cat <<'INSTRUCTIONS'

📝 Post-Install Notes:
======================

The firewall will automatically activate on container start.

To manually apply firewall rules:
  sudo bash /usr/local/bin/init-firewall.sh

To view current rules:
  sudo iptables -L OUTPUT -n -v

To test connectivity:
  curl -v https://github.com        # Should succeed (whitelisted)
  curl -v https://example.com       # Should fail (not whitelisted)

To add more domains at runtime:
  Edit /usr/local/bin/init-firewall.sh and add to ALLOW_DOMAINS array

Security Note:
  - Requires NET_ADMIN capability (already configured in feature)
  - Firewall persists only for container lifetime
  - Recreate container to reset rules

INSTRUCTIONS
