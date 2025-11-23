#!/bin/bash
set -e

echo "Installing Kubernetes Tools..."

INSTALL_KUBECTL="${INSTALLKUBECTL:-true}"
INSTALL_HELM="${INSTALLHELM:-true}"
INSTALL_K9S="${INSTALLK9S:-true}"
INSTALL_KUBECTX="${INSTALLKUBECTX:-true}"
INSTALL_KUSTOMIZE="${INSTALLKUSTOMIZE:-false}"
INSTALL_SKAFFOLD="${INSTALLSKAFFOLD:-false}"

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
apt-get install -y curl

# Install kubectl
if [ "$INSTALL_KUBECTL" = "true" ]; then
    echo "Installing kubectl..."
    KUBECTL_VERSION=$(curl -fsSL https://dl.k8s.io/release/stable.txt) || {
        echo "❌ ERROR: Failed to fetch kubectl stable version"
        exit 1
    }
    curl -fsSL "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl" -o kubectl || {
        echo "❌ ERROR: Failed to download kubectl"
        exit 1
    }
    install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
    rm kubectl
fi

# Install Helm
if [ "$INSTALL_HELM" = "true" ]; then
    echo "Installing Helm..."

    # Helm install script details
    HELM_SCRIPT_URL="https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3"
    HELM_SCRIPT="/tmp/get-helm-3.sh"
    # Checksum verified on 2025-11-23
    HELM_CHECKSUM="38b65f882d9cae3891755bdb03becc6a01ae6f9cb24826c191f219ddfee70a5d"

    # Download installer script
    curl -fsSL "$HELM_SCRIPT_URL" -o "$HELM_SCRIPT" || {
        echo "❌ ERROR: Failed to download Helm installer"
        exit 1
    }

    # Verify checksum
    verify_checksum "$HELM_SCRIPT" "$HELM_CHECKSUM" "Helm installer" || {
        echo "⚠️  WARNING: Checksum verification failed. The installer script may have been updated."
        echo "To update the checksum, run:"
        echo "  curl -fsSL $HELM_SCRIPT_URL | sha256sum"
        exit 1
    }

    # Execute installer
    bash "$HELM_SCRIPT"
    rm "$HELM_SCRIPT"
fi

# Install k9s
if [ "$INSTALL_K9S" = "true" ]; then
    echo "Installing k9s..."
    K9S_VERSION=$(curl -fsSL https://api.github.com/repos/derailed/k9s/releases/latest | grep tag_name | cut -d '"' -f 4) || {
        echo "❌ ERROR: Failed to fetch k9s latest version"
        exit 1
    }
    curl -fsSL "https://github.com/derailed/k9s/releases/download/${K9S_VERSION}/k9s_Linux_amd64.tar.gz" -o /tmp/k9s.tar.gz || {
        echo "❌ ERROR: Failed to download k9s"
        exit 1
    }
    tar xz -C /usr/local/bin k9s -f /tmp/k9s.tar.gz
    rm /tmp/k9s.tar.gz
fi

# Install kubectx and kubens
if [ "$INSTALL_KUBECTX" = "true" ]; then
    echo "Installing kubectx and kubens..."
    git clone https://github.com/ahmetb/kubectx /opt/kubectx
    ln -s /opt/kubectx/kubectx /usr/local/bin/kubectx
    ln -s /opt/kubectx/kubens /usr/local/bin/kubens
fi

# Install kustomize
if [ "$INSTALL_KUSTOMIZE" = "true" ]; then
    echo "Installing kustomize..."

    # Kustomize install script details
    KUSTOMIZE_SCRIPT_URL="https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh"
    KUSTOMIZE_SCRIPT="/tmp/install_kustomize.sh"
    # Checksum verified on 2025-11-23
    KUSTOMIZE_CHECKSUM="8b5be5e4993a708717d1dc4db2db3af6bf5bb2d70d17e878cd04fdf3008fb13e"

    # Download installer script
    curl -fsSL "$KUSTOMIZE_SCRIPT_URL" -o "$KUSTOMIZE_SCRIPT" || {
        echo "❌ ERROR: Failed to download kustomize installer"
        exit 1
    }

    # Verify checksum
    verify_checksum "$KUSTOMIZE_SCRIPT" "$KUSTOMIZE_CHECKSUM" "kustomize installer" || {
        echo "⚠️  WARNING: Checksum verification failed. The installer script may have been updated."
        echo "To update the checksum, run:"
        echo "  curl -fsSL $KUSTOMIZE_SCRIPT_URL | sha256sum"
        exit 1
    }

    # Execute installer
    bash "$KUSTOMIZE_SCRIPT"
    mv kustomize /usr/local/bin/
    rm "$KUSTOMIZE_SCRIPT"
fi

# Install skaffold
if [ "$INSTALL_SKAFFOLD" = "true" ]; then
    echo "Installing skaffold..."
    curl -fsSL https://storage.googleapis.com/skaffold/releases/latest/skaffold-linux-amd64 -o skaffold || {
        echo "❌ ERROR: Failed to download skaffold"
        exit 1
    }
    install skaffold /usr/local/bin/
    rm skaffold
fi

apt-get clean
rm -rf /var/lib/apt/lists/*

echo "✅ Kubernetes tools installation complete!"
echo ""
echo "Installed tools:"
[ "$INSTALL_KUBECTL" = "true" ] && echo "  ✓ kubectl - $(kubectl version --client --short 2>/dev/null || echo 'installed')"
[ "$INSTALL_HELM" = "true" ] && echo "  ✓ helm - $(helm version --short)"
[ "$INSTALL_K9S" = "true" ] && echo "  ✓ k9s - $(k9s version --short)"
[ "$INSTALL_KUBECTX" = "true" ] && echo "  ✓ kubectx/kubens"
[ "$INSTALL_KUSTOMIZE" = "true" ] && echo "  ✓ kustomize - $(kustomize version --short)"
[ "$INSTALL_SKAFFOLD" = "true" ] && echo "  ✓ skaffold - $(skaffold version)"
echo ""
