# Offline Mode Feature

Configure dev container for air-gapped/offline operation with no external network access.

## Features

✅ **Complete Network Isolation** - Block all external connectivity
✅ **Localhost Access** - Keep local services working
✅ **Private Network Support** - Optional LAN access
✅ **Package Caching** - Pre-download common packages
✅ **Easy Toggle** - Enable/disable as needed

## Usage

```json
{
  "features": {
    "ghcr.io/xrf9268-hue/features/offline-mode:1": {
      "blockAllExternal": true,
      "allowPrivateNetworks": false,
      "cachePackages": true
    }
  }
}
```

## Commands

```bash
# Enable offline mode
enable-offline-mode

# Disable offline mode
disable-offline-mode

# Check status
offline-mode-status
```

## Use Cases

- **Air-gapped environments** - Military, government
- **ITAR compliance** - No data export
- **HIPAA compliance** - Data isolation
- **Zero-trust networks** - Assume breach
- **Classified development** - Sensitive projects

## Configuration

**What's Allowed:**
- Localhost (127.0.0.1)
- Docker internal (host.docker.internal)
- Optionally: Private networks (10.x, 192.168.x)

**What's Blocked:**
- All internet traffic
- Cloud services
- External APIs
- Package registries (use cache)
