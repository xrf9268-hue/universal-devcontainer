#!/bin/bash
set -e

echo "Installing Cloud CLI Tools..."

INSTALL_AWS_CLI="${INSTALLAWSCLI:-true}"
INSTALL_GCLOUD="${INSTALLGCLOUD:-false}"
INSTALL_AZURE_CLI="${INSTALLAZURECLI:-false}"
INSTALL_DOCTL="${INSTALLDOCTL:-false}"

apt-get update
apt-get install -y curl unzip

# Install AWS CLI
if [ "$INSTALL_AWS_CLI" = "true" ]; then
    echo "Installing AWS CLI v2..."
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip -q awscliv2.zip
    ./aws/install
    rm -rf aws awscliv2.zip
fi

# Install Google Cloud SDK
if [ "$INSTALL_GCLOUD" = "true" ]; then
    echo "Installing Google Cloud SDK..."
    echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
    curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -
    apt-get update
    apt-get install -y google-cloud-sdk
fi

# Install Azure CLI
if [ "$INSTALL_AZURE_CLI" = "true" ]; then
    echo "Installing Azure CLI..."
    curl -sL https://aka.ms/InstallAzureCLIDeb -o /tmp/install-azure-cli.sh
    bash /tmp/install-azure-cli.sh
    rm /tmp/install-azure-cli.sh
fi

# Install DigitalOcean CLI
if [ "$INSTALL_DOCTL" = "true" ]; then
    echo "Installing DigitalOcean CLI (doctl)..."
    cd /usr/local/bin
    curl -sL https://github.com/digitalocean/doctl/releases/download/v1.94.0/doctl-1.94.0-linux-amd64.tar.gz | tar -xzv
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
