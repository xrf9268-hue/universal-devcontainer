#!/bin/bash
set -e

echo "Installing Database Tools..."

INSTALL_PGCLI="${INSTALLPGCLI:-true}"
INSTALL_MYCLI="${INSTALLMYCLI:-true}"
INSTALL_REDIS_CLI="${INSTALLREDISCLI:-true}"
INSTALL_MONGOSH="${INSTALLMONGOSH:-false}"
INSTALL_LITECLI="${INSTALLLITECLI:-false}"

apt-get update

# Install Python pip if not available
if ! command -v pip3 &> /dev/null; then
    apt-get install -y python3-pip
fi

# Install pgcli
if [ "$INSTALL_PGCLI" = "true" ]; then
    echo "Installing pgcli..."
    pip3 install --no-cache-dir pgcli==4.0.1
fi

# Install mycli
if [ "$INSTALL_MYCLI" = "true" ]; then
    echo "Installing mycli..."
    pip3 install --no-cache-dir mycli==1.27.0
fi

# Install redis-cli
if [ "$INSTALL_REDIS_CLI" = "true" ]; then
    echo "Installing redis-cli..."
    apt-get install -y redis-tools
fi

# Install mongosh
if [ "$INSTALL_MONGOSH" = "true" ]; then
    echo "Installing mongosh..."
    curl -fsSL https://pgp.mongodb.com/server-6.0.asc | gpg --dearmor -o /usr/share/keyrings/mongodb-archive-keyring.gpg
    echo "deb [signed-by=/usr/share/keyrings/mongodb-archive-keyring.gpg] https://repo.mongodb.org/apt/debian bullseye/mongodb-org/6.0 main" | tee /etc/apt/sources.list.d/mongodb-org-6.0.list
    apt-get update
    apt-get install -y mongodb-mongosh
fi

# Install litecli
if [ "$INSTALL_LITECLI" = "true" ]; then
    echo "Installing litecli..."
    pip3 install --no-cache-dir litecli==1.11.0
fi

apt-get clean
rm -rf /var/lib/apt/lists/*

echo "✅ Database tools installation complete!"
echo ""
echo "Installed tools:"
[ "$INSTALL_PGCLI" = "true" ] && echo "  ✓ pgcli - PostgreSQL CLI"
[ "$INSTALL_MYCLI" = "true" ] && echo "  ✓ mycli - MySQL CLI"
[ "$INSTALL_REDIS_CLI" = "true" ] && echo "  ✓ redis-cli"
[ "$INSTALL_MONGOSH" = "true" ] && echo "  ✓ mongosh - MongoDB Shell"
[ "$INSTALL_LITECLI" = "true" ] && echo "  ✓ litecli - SQLite CLI"
echo ""
