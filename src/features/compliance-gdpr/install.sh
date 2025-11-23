#!/bin/bash
set -e

echo "Installing GDPR Compliance Tools..."

ENABLE_ENCRYPTION="${ENABLEDATAENCRYPTION:-true}"
ENABLE_PII="${ENABLEPIIDETECTION:-true}"
RETENTION_DAYS="${DATARETENTIONDAYS:-30}"
ENABLE_ERASURE="${ENABLERIGHTTOERASURE:-true}"
ENABLE_PORTABILITY="${ENABLEDATAPORTABILITY:-true}"
ENABLE_CONSENT="${ENABLECONSENTTRACKING:-false}"

apt-get update
apt-get install -y gnupg2 git-crypt jq

# Create GDPR configuration
mkdir -p /etc/gdpr-compliance
cat > /etc/gdpr-compliance/config.json <<EOF
{
  "encryption_enabled": $ENABLE_ENCRYPTION,
  "pii_detection_enabled": $ENABLE_PII,
  "data_retention_days": $RETENTION_DAYS,
  "right_to_erasure_enabled": $ENABLE_ERASURE,
  "data_portability_enabled": $ENABLE_PORTABILITY,
  "consent_tracking_enabled": $ENABLE_CONSENT,
  "configured_at": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
}
EOF

# PII Detection tool
if [ "$ENABLE_PII" = "true" ]; then
    cat > /usr/local/bin/detect-pii <<'SCRIPT'
#!/bin/bash
# Detect PII in files

TARGET="${1:-.}"

echo "Scanning for PII in: $TARGET"
echo "================================"

# Common PII patterns
declare -A patterns=(
    ["Email"]='[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}'
    ["SSN"]='[0-9]{3}-[0-9]{2}-[0-9]{4}'
    ["Credit Card"]='[0-9]{4}[- ]?[0-9]{4}[- ]?[0-9]{4}[- ]?[0-9]{4}'
    ["Phone"]='(\+?1[-.]?)?\(?([0-9]{3})\)?[-.]?([0-9]{3})[-.]?([0-9]{4})'
    ["IP Address"]='([0-9]{1,3}\.){3}[0-9]{1,3}'
)

found=0
for pii_type in "${!patterns[@]}"; do
    matches=$(grep -rE "${patterns[$pii_type]}" "$TARGET" 2>/dev/null | wc -l)
    if [ $matches -gt 0 ]; then
        echo "⚠️  Found $matches potential $pii_type instances"
        found=$((found + matches))
    fi
done

if [ $found -eq 0 ]; then
    echo "✅ No obvious PII detected"
else
    echo ""
    echo "⚠️  Total PII instances found: $found"
    echo "   Review these files for GDPR compliance"
fi
SCRIPT
    chmod +x /usr/local/bin/detect-pii
fi

# Data Encryption tool
if [ "$ENABLE_ENCRYPTION" = "true" ]; then
    cat > /usr/local/bin/gdpr-encrypt <<'SCRIPT'
#!/bin/bash
# Encrypt sensitive data files

FILE=$1
if [ -z "$FILE" ]; then
    echo "Usage: gdpr-encrypt <file>"
    exit 1
fi

if [ ! -f "$FILE" ]; then
    echo "Error: File not found: $FILE"
    exit 1
fi

# Encrypt with GPG
gpg --symmetric --cipher-algo AES256 "$FILE"
echo "✅ Encrypted: $FILE.gpg"
echo "   Original file preserved"
echo ""
echo "To decrypt: gpg --decrypt $FILE.gpg > $FILE"
SCRIPT
    chmod +x /usr/local/bin/gdpr-encrypt
fi

# Data Erasure tool (Right to be Forgotten)
if [ "$ENABLE_ERASURE" = "true" ]; then
    cat > /usr/local/bin/gdpr-erase <<'SCRIPT'
#!/bin/bash
# Securely erase data (GDPR Article 17)

TARGET=$1
if [ -z "$TARGET" ]; then
    echo "Usage: gdpr-erase <file_or_directory>"
    exit 1
fi

if [ ! -e "$TARGET" ]; then
    echo "Error: Not found: $TARGET"
    exit 1
fi

echo "⚠️  GDPR Data Erasure (Right to be Forgotten)"
echo "This will PERMANENTLY and SECURELY erase: $TARGET"
read -p "Are you sure? [yes/NO]: " confirm

if [ "$confirm" != "yes" ]; then
    echo "Cancelled"
    exit 0
fi

# Secure deletion (overwrite 3 times)
if command -v shred &> /dev/null; then
    if [ -f "$TARGET" ]; then
        shred -vfz -n 3 "$TARGET"
    elif [ -d "$TARGET" ]; then
        find "$TARGET" -type f -exec shred -vfz -n 3 {} \;
        rm -rf "$TARGET"
    fi
    echo "✅ Securely erased: $TARGET"
else
    # Fallback to rm
    rm -rf "$TARGET"
    echo "✅ Deleted: $TARGET (secure deletion not available)"
fi

# Log erasure
echo "$(date -u +"%Y-%m-%dT%H:%M:%SZ") - Erased: $TARGET" >> /var/log/gdpr-erasures.log
SCRIPT
    chmod +x /usr/local/bin/gdpr-erase
fi

# Data Export tool (Data Portability)
if [ "$ENABLE_PORTABILITY" = "true" ]; then
    cat > /usr/local/bin/gdpr-export <<'SCRIPT'
#!/bin/bash
# Export data in portable format (GDPR Article 20)

SOURCE=$1
OUTPUT=${2:-gdpr-export-$(date +%Y%m%d-%H%M%S).tar.gz}

if [ -z "$SOURCE" ]; then
    echo "Usage: gdpr-export <source_directory> [output_file.tar.gz]"
    exit 1
fi

if [ ! -d "$SOURCE" ]; then
    echo "Error: Directory not found: $SOURCE"
    exit 1
fi

echo "Exporting data for portability..."
tar czf "$OUTPUT" -C "$(dirname "$SOURCE")" "$(basename "$SOURCE")"

echo "✅ Data exported to: $OUTPUT"
echo ""
echo "This archive contains data in portable format per GDPR Article 20"
echo "Hash: $(sha256sum "$OUTPUT" | awk '{print $1}')"

# Log export
echo "$(date -u +"%Y-%m-%dT%H:%M:%SZ") - Exported: $SOURCE -> $OUTPUT" >> /var/log/gdpr-exports.log
SCRIPT
    chmod +x /usr/local/bin/gdpr-export
fi

# Data Retention checker
cat > /usr/local/bin/gdpr-check-retention <<SCRIPT
#!/bin/bash
# Check for files older than retention period

RETENTION_DAYS=$RETENTION_DAYS
SEARCH_PATH=\${1:-.}

echo "GDPR Data Retention Check"
echo "========================="
echo "Retention period: \$RETENTION_DAYS days"
echo "Searching: \$SEARCH_PATH"
echo ""

# Find files older than retention period
old_files=\$(find "\$SEARCH_PATH" -type f -mtime +\$RETENTION_DAYS 2>/dev/null)

if [ -z "\$old_files" ]; then
    echo "✅ No files exceed retention period"
else
    count=\$(echo "\$old_files" | wc -l)
    echo "⚠️  Found \$count files exceeding retention period:"
    echo ""
    echo "\$old_files" | head -20
    if [ \$count -gt 20 ]; then
        echo "... and \$((count - 20)) more"
    fi
    echo ""
    echo "Consider using 'gdpr-erase' to remove old data"
fi
SCRIPT
chmod +x /usr/local/bin/gdpr-check-retention

# Create GDPR compliance checklist
cat > /usr/share/doc/gdpr-compliance-checklist.md <<EOF
# GDPR Compliance Checklist

## Data Protection Principles (Article 5)

- [ ] **Lawfulness, fairness, transparency** - Document legal basis for processing
- [ ] **Purpose limitation** - Only collect data for specified purposes
- [ ] **Data minimization** - Only collect necessary data
- [ ] **Accuracy** - Keep data accurate and up-to-date
- [ ] **Storage limitation** - Don't keep data longer than necessary
- [ ] **Integrity and confidentiality** - Secure data against unauthorized access
- [ ] **Accountability** - Demonstrate compliance

## Individual Rights

- [ ] **Right to access** (Article 15) - Provide data on request
- [ ] **Right to rectification** (Article 16) - Allow data corrections
- [ ] **Right to erasure** (Article 17) - Delete data on request
  - Use: \`gdpr-erase <file>\`
- [ ] **Right to data portability** (Article 20) - Export data in portable format
  - Use: \`gdpr-export <directory>\`
- [ ] **Right to object** (Article 21) - Stop processing on request

## Security Measures (Article 32)

- [ ] **Encryption** - Encrypt sensitive data
  - Use: \`gdpr-encrypt <file>\`
- [ ] **Access controls** - Limit who can access data
- [ ] **Audit logging** - Track data access and changes
- [ ] **Data breach procedures** - Plan for breaches

## Data Processing

- [ ] **Data retention** - Delete data after retention period
  - Check: \`gdpr-check-retention\`
  - Configured retention: $RETENTION_DAYS days
- [ ] **PII detection** - Identify and protect personal data
  - Scan: \`detect-pii\`
- [ ] **Data minimization** - Only store what's needed
- [ ] **Anonymization/Pseudonymization** - Where possible

## Documentation

- [ ] **Privacy policy** - Document how data is processed
- [ ] **Data processing records** (Article 30) - Maintain records
- [ ] **DPIAs** - Conduct when needed (Article 35)
- [ ] **Data breach register** - Track incidents

## Tools Installed

- \`detect-pii\` - Scan for PII in files
- \`gdpr-encrypt\` - Encrypt sensitive data
- \`gdpr-erase\` - Securely delete data (Right to Erasure)
- \`gdpr-export\` - Export data (Data Portability)
- \`gdpr-check-retention\` - Check data age against retention policy

## Logs

- Erasures: /var/log/gdpr-erasures.log
- Exports: /var/log/gdpr-exports.log
- Configuration: /etc/gdpr-compliance/config.json
EOF

# Create log files
touch /var/log/gdpr-erasures.log
touch /var/log/gdpr-exports.log
chmod 644 /var/log/gdpr-*.log

apt-get clean
rm -rf /var/lib/apt/lists/*

echo "✅ GDPR Compliance tools installed successfully!"
echo ""
echo "Tools:"
[ "$ENABLE_PII" = "true" ] && echo "  detect-pii              - Scan for PII"
[ "$ENABLE_ENCRYPTION" = "true" ] && echo "  gdpr-encrypt <file>     - Encrypt sensitive data"
[ "$ENABLE_ERASURE" = "true" ] && echo "  gdpr-erase <path>       - Secure data erasure"
[ "$ENABLE_PORTABILITY" = "true" ] && echo "  gdpr-export <dir>       - Export data"
echo "  gdpr-check-retention    - Check retention compliance"
echo ""
echo "Documentation: /usr/share/doc/gdpr-compliance-checklist.md"
echo "Configuration: /etc/gdpr-compliance/config.json"
echo ""
