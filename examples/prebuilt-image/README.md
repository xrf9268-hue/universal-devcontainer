# Using Pre-built Container Image

This example shows how to use the pre-built Universal Dev Container image instead of building from Dockerfile.

## Benefits

- ⚡ **Fast startup** - No build time, instant container start (3-5 seconds)
- 📦 **Consistency** - Same base image across all projects
- 🔄 **Easy updates** - Pull new image version instead of rebuilding
- 💾 **Disk space** - Share base image across multiple projects
- 🚀 **Multi-arch** - Supports both amd64 and arm64

## Performance Comparison

| Method | First Time | Subsequent |
|--------|-----------|------------|
| Build from Dockerfile | ~10 min | ~30 sec |
| Pre-built image | ~1 min (pull) | ~5 sec |

**Improvement**: ~70% faster for first-time setup, ~80% faster for subsequent starts

## Usage

### Option 1: Latest Version

Use the latest stable release:

```json
{
  "image": "ghcr.io/xrf9268-hue/universal-devcontainer:latest"
}
```

### Option 2: Specific Version

Pin to a specific version for stability:

```json
{
  "image": "ghcr.io/xrf9268-hue/universal-devcontainer:2.1"
}
```

### Option 3: Development Version

Use the development version (built from main branch):

```json
{
  "image": "ghcr.io/xrf9268-hue/universal-devcontainer:main"
}
```

## Complete Example

See `devcontainer.json` in this directory for a complete working example.

## Updating the Image

To pull the latest version:

```bash
docker pull ghcr.io/xrf9268-hue/universal-devcontainer:latest
```

Then rebuild your container in VS Code:
- Press `Cmd/Ctrl + Shift + P`
- Select "Dev Containers: Rebuild Container"

## Custom Features on Top

You can add additional Dev Container Features on top of the pre-built image:

```json
{
  "image": "ghcr.io/xrf9268-hue/universal-devcontainer:latest",
  "features": {
    "ghcr.io/devcontainers/features/docker-in-docker:2": {},
    "ghcr.io/devcontainers/features/aws-cli:1": {}
  }
}
```

## Available Platforms

The image is built for multiple architectures:

- `linux/amd64` (Intel/AMD)
- `linux/arm64` (Apple Silicon, ARM servers)

Docker automatically pulls the correct platform.

## Image Tags

| Tag | Description | Update Frequency |
|-----|-------------|------------------|
| `latest` | Latest stable release | On each release |
| `2.1`, `2` | Specific versions | Immutable |
| `main` | Development build | On main branch changes |

## Local Testing

To test the pre-built image locally:

```bash
# Pull the image
docker pull ghcr.io/xrf9268-hue/universal-devcontainer:latest

# Run interactively
docker run -it --rm ghcr.io/xrf9268-hue/universal-devcontainer:latest

# Verify tools
node --version
python3 --version
zsh --version
```

## Building Locally

If you want to build the image yourself:

```bash
# From repository root
docker build -f Dockerfile.prebuilt -t universal-devcontainer:local .

# Use in devcontainer.json
{
  "image": "universal-devcontainer:local"
}
```

## Troubleshooting

### Image not found

Make sure the repository is public or you're authenticated:

```bash
echo $GITHUB_TOKEN | docker login ghcr.io -u USERNAME --password-stdin
```

### Old version being used

Clear Docker cache:

```bash
docker system prune -a
docker pull ghcr.io/xrf9268-hue/universal-devcontainer:latest
```

### Slow pull on first use

This is normal. The image is ~500MB-1GB. Subsequent pulls only download changed layers.

## Migration Guide

### From Dockerfile to Pre-built Image

**Before** (using Dockerfile):
```json
{
  "build": {
    "dockerfile": "Dockerfile"
  }
}
```

**After** (using pre-built image):
```json
{
  "image": "ghcr.io/xrf9268-hue/universal-devcontainer:latest"
}
```

**Benefits**: 70% faster startup, no local build required.

## Links

- **Image Registry**: https://github.com/xrf9268-hue/universal-devcontainer/pkgs/container/universal-devcontainer
- **Main Documentation**: ../../README.md
- **Dockerfile Source**: ../../Dockerfile.prebuilt
