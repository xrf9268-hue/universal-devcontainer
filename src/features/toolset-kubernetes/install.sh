#!/bin/bash
set -e

echo "Installing Kubernetes Tools..."

INSTALL_KUBECTL="${INSTALLKUBECTL:-true}"
INSTALL_HELM="${INSTALLHELM:-true}"
INSTALL_K9S="${INSTALLK9S:-true}"
INSTALL_KUBECTX="${INSTALLKUBECTX:-true}"
INSTALL_KUSTOMIZE="${INSTALLKUSTOMIZE:-false}"
INSTALL_SKAFFOLD="${INSTALLSKAFFOLD:-false}"

apt-get update
apt-get install -y curl

# Install kubectl
if [ "$INSTALL_KUBECTL" = "true" ]; then
    echo "Installing kubectl..."
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
    rm kubectl
fi

# Install Helm
if [ "$INSTALL_HELM" = "true" ]; then
    echo "Installing Helm..."
    curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 -o /tmp/get-helm-3.sh
    bash /tmp/get-helm-3.sh
    rm /tmp/get-helm-3.sh
fi

# Install k9s
if [ "$INSTALL_K9S" = "true" ]; then
    echo "Installing k9s..."
    K9S_VERSION=$(curl -s https://api.github.com/repos/derailed/k9s/releases/latest | grep tag_name | cut -d '"' -f 4)
    curl -sL "https://github.com/derailed/k9s/releases/download/${K9S_VERSION}/k9s_Linux_amd64.tar.gz" | tar xz -C /usr/local/bin k9s
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
    curl -s "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh" -o /tmp/install_kustomize.sh
    bash /tmp/install_kustomize.sh
    mv kustomize /usr/local/bin/
    rm /tmp/install_kustomize.sh
fi

# Install skaffold
if [ "$INSTALL_SKAFFOLD" = "true" ]; then
    echo "Installing skaffold..."
    curl -Lo skaffold https://storage.googleapis.com/skaffold/releases/latest/skaffold-linux-amd64
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
