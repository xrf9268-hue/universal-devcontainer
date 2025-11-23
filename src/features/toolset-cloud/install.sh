#!/bin/bash
set -e

echo "Installing Cloud CLI Tools..."

INSTALL_AWS_CLI="${INSTALLAWSCLI:-true}"
INSTALL_GCLOUD="${INSTALLGCLOUD:-false}"
INSTALL_AZURE_CLI="${INSTALLAZURECLI:-false}"
INSTALL_DOCTL="${INSTALLDOCTL:-false}"

# Helper function for checksum verification
verify_checksum() {
    local file="$1"
    local expected_checksum="$2"
    local description="$3"

    echo "Verifying $description checksum..."
    echo "$expected_checksum  $file" | sha256sum -c - > /dev/null 2>&1 || {
        echo "❌ ERROR: Checksum verification failed for $description"
        echo "Expected: $expected_checksum"
        echo "Got:      $(sha256sum "$file" | cut -d' ' -f1)"
        rm -f "$file"
        return 1
    }
    echo "✓ Checksum verified"
    return 0
}

apt-get update
apt-get install -y curl unzip

# Install AWS CLI
if [ "$INSTALL_AWS_CLI" = "true" ]; then
    echo "Installing AWS CLI v2..."
    curl -fsSL "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" || {
        echo "❌ ERROR: Failed to download AWS CLI"
        exit 1
    }
    unzip -q awscliv2.zip
    ./aws/install
    rm -rf aws awscliv2.zip
fi

# Install Google Cloud SDK
if [ "$INSTALL_GCLOUD" = "true" ]; then
    echo "Installing Google Cloud SDK..."
    echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
    curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key --keyring /usr/share/keyrings/cloud.google.gpg add - || {
        echo "❌ ERROR: Failed to download Google Cloud SDK GPG key"
        exit 1
    }
    apt-get update
    apt-get install -y google-cloud-sdk
fi

# Install Azure CLI
if [ "$INSTALL_AZURE_CLI" = "true" ]; then
    echo "Installing Azure CLI..."

    # Azure CLI install script details
    AZURE_SCRIPT_URL="https://aka.ms/InstallAzureCLIDeb"
    AZURE_SCRIPT="/tmp/install-azure-cli.sh"
    # Checksum verified on 2025-11-23
    AZURE_CHECKSUM="01fada4dafe903fa6edae138d3e3ca2e6e4295d7c8a35e48632bba4aa9dbe9d9"

    # Download installer script
    curl -fsSL "$AZURE_SCRIPT_URL" -o "$AZURE_SCRIPT" || {
        echo "❌ ERROR: Failed to download Azure CLI installer"
        exit 1
    }

    # Verify checksum
    verify_checksum "$AZURE_SCRIPT" "$AZURE_CHECKSUM" "Azure CLI installer" || {
        echo "⚠️  WARNING: Checksum verification failed. The installer script may have been updated."
        echo "To update the checksum, run:"
        echo "  curl -fsSL $AZURE_SCRIPT_URL | sha256sum"
        exit 1
    }

    # Execute installer
    bash "$AZURE_SCRIPT"
    rm "$AZURE_SCRIPT"
fi

# Install DigitalOcean CLI
if [ "$INSTALL_DOCTL" = "true" ]; then
    echo "Installing DigitalOcean CLI (doctl)..."
    DOCTL_VERSION="1.94.0"
    DOCTL_URL="https://github.com/digitalocean/doctl/releases/download/v${DOCTL_VERSION}/doctl-${DOCTL_VERSION}-linux-amd64.tar.gz"

    curl -fsSL "$DOCTL_URL" -o /tmp/doctl.tar.gz || {
        echo "❌ ERROR: Failed to download doctl"
        exit 1
    }

    tar -xzf /tmp/doctl.tar.gz -C /usr/local/bin
    rm /tmp/doctl.tar.gz
fi

apt-get clean
rm -rf /var/lib/apt/lists/*

echo "✅ Cloud CLI tools installation complete!"
echo ""
echo "Installed tools:"
[ "$INSTALL_AWS_CLI" = "true" ] && echo "  ✓ aws - $(aws --version)"
[ "$INSTALL_GCLOUD" = "true" ] && echo "  ✓ gcloud - $(gcloud --version | head -1)"
[ "$INSTALL_AZURE_CLI" = "true" ] && echo "  ✓ az - $(az --version | head -1)"
[ "$INSTALL_DOCTL" = "true" ] && echo "  ✓ doctl - $(doctl version)"
echo ""
