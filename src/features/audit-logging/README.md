# Audit Logging Feature

Comprehensive audit logging for SOC 2, ISO 27001, and enterprise compliance requirements.

## Features

✅ **File Operation Logging** - Track all read/write/delete operations
✅ **Network Request Logging** - Log outbound network calls
✅ **Command Execution Logging** - Record shell commands
✅ **Git Operation Logging** - Track commits, pushes, pulls
✅ **SIEM Integration** - Forward logs to security systems
✅ **Configurable Retention** - Automatic log rotation
✅ **JSON Format** - Structured, parseable logs

## Usage

```json
{
  "features": {
    "ghcr.io/xrf9268-hue/features/audit-logging:1": {
      "logLevel": "info",
      "retentionDays": 90,
      "enableSIEM": false
    }
  }
}
```

## Commands

```bash
# Log custom event
audit-log file_write "/path/to/file"
audit-log network_request "https://api.example.com"

# View audit report
audit-report

# View raw logs
cat /var/log/devcontainer-audit/audit.log
```

## Compliance

- **SOC 2** - Type II audit trail
- **ISO 27001** - Information security logs
- **HIPAA** - Access logging requirements
- **PCI DSS** - System activity tracking
