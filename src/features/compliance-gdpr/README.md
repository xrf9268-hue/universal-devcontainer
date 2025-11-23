# GDPR Compliance Feature

Tools and configurations for GDPR data protection compliance.

## Features

✅ **PII Detection** - Scan for personally identifiable information
✅ **Data Encryption** - Protect sensitive data at rest
✅ **Right to Erasure** - Secure data deletion (Article 17)
✅ **Data Portability** - Export data (Article 20)
✅ **Retention Management** - Enforce retention policies
✅ **Audit Trail** - Log erasures and exports

## Usage

```json
{
  "features": {
    "ghcr.io/xrf9268-hue/features/compliance-gdpr:1": {
      "enablePIIDetection": true,
      "enableDataEncryption": true,
      "dataRetentionDays": 30,
      "enableRightToErasure": true,
      "enableDataPortability": true
    }
  }
}
```

## Commands

```bash
# Detect PII in code/files
detect-pii .
detect-pii src/

# Encrypt sensitive data
gdpr-encrypt sensitive-file.json

# Securely erase data (Right to be Forgotten)
gdpr-erase old-user-data/

# Export data (Data Portability)
gdpr-export user-data/ export.tar.gz

# Check retention compliance
gdpr-check-retention /workspace
```

## GDPR Articles Covered

- **Article 5** - Data Protection Principles
- **Article 15** - Right to Access
- **Article 16** - Right to Rectification
- **Article 17** - Right to Erasure
- **Article 20** - Right to Data Portability
- **Article 30** - Records of Processing
- **Article 32** - Security Measures

## Compliance Checklist

See `/usr/share/doc/gdpr-compliance-checklist.md` for complete checklist.

## Logs

- Erasures: `/var/log/gdpr-erasures.log`
- Exports: `/var/log/gdpr-exports.log`
- Configuration: `/etc/gdpr-compliance/config.json`
