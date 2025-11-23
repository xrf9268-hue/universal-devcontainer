#!/bin/bash
set -e

echo "Installing Developer Tools..."

# Parse options
INCLUDE_TOOLS="${INCLUDETOOLS:-essential}"
INSTALL_LAZYGIT="${INSTALLLAZYGIT:-true}"
INSTALL_BAT="${INSTALLBAT:-true}"
INSTALL_FZF="${INSTALLFZF:-true}"
INSTALL_HTTPIE="${INSTALLHTTPIE:-true}"
INSTALL_RIPGREP="${INSTALLRIPGREP:-true}"
INSTALL_EZA="${INSTALLEZA:-false}"
INSTALL_DELTA="${INSTALLDELTA:-false}"

# Override individual options based on preset
case "$INCLUDE_TOOLS" in
    all)
        INSTALL_LAZYGIT="true"
        INSTALL_BAT="true"
        INSTALL_FZF="true"
        INSTALL_HTTPIE="true"
        INSTALL_RIPGREP="true"
        INSTALL_EZA="true"
        INSTALL_DELTA="true"
        ;;
    minimal)
        INSTALL_LAZYGIT="false"
        INSTALL_BAT="false"
        INSTALL_FZF="true"
        INSTALL_HTTPIE="false"
        INSTALL_RIPGREP="true"
        INSTALL_EZA="false"
        INSTALL_DELTA="false"
        ;;
    essential)
        # Use individual flags (default)
        ;;
esac

# Update package lists
apt-get update

# Install jq (needed by many tools)
apt-get install -y jq curl wget ca-certificates gnupg

# Install ripgrep
if [ "$INSTALL_RIPGREP" = "true" ]; then
    echo "Installing ripgrep..."
    apt-get install -y ripgrep
fi

# Install fzf
if [ "$INSTALL_FZF" = "true" ]; then
    echo "Installing fzf..."
    apt-get install -y fzf
fi

# Install bat
if [ "$INSTALL_BAT" = "true" ]; then
    echo "Installing bat..."
    apt-get install -y bat
    # Create symlink (Debian/Ubuntu package is named 'batcat')
    if [ ! -e /usr/local/bin/bat ] && [ -e /usr/bin/batcat ]; then
        ln -s /usr/bin/batcat /usr/local/bin/bat
    fi
fi

# Install httpie
if [ "$INSTALL_HTTPIE" = "true" ]; then
    echo "Installing httpie..."
    apt-get install -y httpie
fi

# Install lazygit
if [ "$INSTALL_LAZYGIT" = "true" ]; then
    echo "Installing lazygit..."
    LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
    curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
    tar xf lazygit.tar.gz lazygit
    install lazygit /usr/local/bin
    rm lazygit lazygit.tar.gz
fi

# Install eza (modern ls)
if [ "$INSTALL_EZA" = "true" ]; then
    echo "Installing eza..."
    mkdir -p /etc/apt/keyrings
    wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
    echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | tee /etc/apt/sources.list.d/gierens.list
    chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list
    apt-get update
    apt-get install -y eza
fi

# Install delta (better git diff)
if [ "$INSTALL_DELTA" = "true" ]; then
    echo "Installing delta..."
    DELTA_VERSION=$(curl -s "https://api.github.com/repos/dandavison/delta/releases/latest" | grep -Po '"tag_name": "\K[^"]*')
    curl -Lo delta.deb "https://github.com/dandavison/delta/releases/latest/download/git-delta_${DELTA_VERSION}_amd64.deb"
    dpkg -i delta.deb
    rm delta.deb
fi

# Clean up
apt-get clean
rm -rf /var/lib/apt/lists/*

echo "✅ Developer tools installation complete!"

# Show installed tools
echo ""
echo "Installed tools:"
[ "$INSTALL_RIPGREP" = "true" ] && echo "  ✓ ripgrep (rg) - $(rg --version | head -1)"
[ "$INSTALL_FZF" = "true" ] && echo "  ✓ fzf - $(fzf --version)"
[ "$INSTALL_BAT" = "true" ] && echo "  ✓ bat - $(bat --version)"
[ "$INSTALL_HTTPIE" = "true" ] && echo "  ✓ httpie - $(http --version)"
[ "$INSTALL_LAZYGIT" = "true" ] && echo "  ✓ lazygit - $(lazygit --version | head -1)"
[ "$INSTALL_EZA" = "true" ] && echo "  ✓ eza - $(eza --version | head -1)"
[ "$INSTALL_DELTA" = "true" ] && echo "  ✓ delta - $(delta --version)"
echo ""
