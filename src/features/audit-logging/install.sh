#!/bin/bash
set -e

echo "Installing Audit Logging for Compliance..."

LOG_LEVEL="${LOGLEVEL:-info}"
LOG_FILE_OPS="${LOGFILEOPERATIONS:-true}"
LOG_NETWORK="${LOGNETWORKREQUESTS:-true}"
LOG_COMMANDS="${LOGCOMMANDEXECUTION:-true}"
LOG_GIT="${LOGGITOPERATIONS:-true}"
RETENTION_DAYS="${RETENTIONDAYS:-90}"
ENABLE_SIEM="${ENABLESIEM:-false}"
SIEM_HOST="${SIEMHOST:-}"

# Create audit log directory
AUDIT_DIR="/var/log/devcontainer-audit"
mkdir -p "$AUDIT_DIR"
chmod 755 "$AUDIT_DIR"

# Install auditd for system-level logging
apt-get update
apt-get install -y auditd rsyslog jq

# Create audit logging configuration
cat > /etc/devcontainer-audit.conf <<EOF
# Dev Container Audit Configuration
LOG_LEVEL=$LOG_LEVEL
LOG_FILE_OPERATIONS=$LOG_FILE_OPS
LOG_NETWORK_REQUESTS=$LOG_NETWORK
LOG_COMMAND_EXECUTION=$LOG_COMMANDS
LOG_GIT_OPERATIONS=$LOG_GIT
RETENTION_DAYS=$RETENTION_DAYS
ENABLE_SIEM=$ENABLE_SIEM
SIEM_HOST=$SIEM_HOST
AUDIT_LOG_DIR=$AUDIT_DIR
EOF

# Create audit logging helper script
cat > /usr/local/bin/audit-log <<'SCRIPT'
#!/bin/bash
# Audit logging helper

source /etc/devcontainer-audit.conf

log_event() {
    local event_type=$1
    local event_data=$2
    local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    local username=$(whoami)
    local hostname=$(hostname)

    # Create JSON log entry
    local log_entry=$(jq -n \
        --arg ts "$timestamp" \
        --arg user "$username" \
        --arg host "$hostname" \
        --arg type "$event_type" \
        --arg data "$event_data" \
        '{
            timestamp: $ts,
            user: $user,
            hostname: $host,
            event_type: $type,
            event_data: $data
        }')

    # Write to file
    echo "$log_entry" >> "${AUDIT_LOG_DIR}/audit.log"

    # Send to SIEM if enabled
    if [ "$ENABLE_SIEM" = "true" ] && [ -n "$SIEM_HOST" ]; then
        echo "$log_entry" | nc -w1 -u "$SIEM_HOST" 514 2>/dev/null || true
    fi
}

# Parse arguments
case "$1" in
    file_read)
        [ "$LOG_FILE_OPERATIONS" = "true" ] && log_event "file_read" "$2"
        ;;
    file_write)
        [ "$LOG_FILE_OPERATIONS" = "true" ] && log_event "file_write" "$2"
        ;;
    file_delete)
        [ "$LOG_FILE_OPERATIONS" = "true" ] && log_event "file_delete" "$2"
        ;;
    network_request)
        [ "$LOG_NETWORK_REQUESTS" = "true" ] && log_event "network_request" "$2"
        ;;
    command_exec)
        [ "$LOG_COMMAND_EXECUTION" = "true" ] && log_event "command_exec" "$2"
        ;;
    git_operation)
        [ "$LOG_GIT_OPERATIONS" = "true" ] && log_event "git_operation" "$2"
        ;;
    *)
        log_event "custom" "$1: $2"
        ;;
esac
SCRIPT

chmod +x /usr/local/bin/audit-log

# Create bash profile hook for command logging
cat > /etc/profile.d/audit-commands.sh <<'PROFILE'
# Audit command execution
if [ -n "$BASH_VERSION" ]; then
    export PROMPT_COMMAND='history -a; audit-log command_exec "$(history 1 | sed "s/^[ ]*[0-9]*[ ]*//")" 2>/dev/null'
fi
PROFILE

# Create git hook for git operations
mkdir -p /etc/skel/.git_template/hooks
cat > /etc/skel/.git_template/hooks/post-commit <<'GITHOOK'
#!/bin/bash
audit-log git_operation "commit: $(git log -1 --pretty=%B)"
GITHOOK

cat > /etc/skel/.git_template/hooks/post-push <<'GITHOOK'
#!/bin/bash
audit-log git_operation "push to remote"
GITHOOK

chmod +x /etc/skel/.git_template/hooks/*

# Create log rotation configuration
cat > /etc/logrotate.d/devcontainer-audit <<EOF
${AUDIT_DIR}/audit.log {
    daily
    rotate $RETENTION_DAYS
    compress
    missingok
    notifempty
    create 0644 root root
}
EOF

# Create audit report script
cat > /usr/local/bin/audit-report <<'REPORT'
#!/bin/bash
# Generate audit report

source /etc/devcontainer-audit.conf

echo "==================================="
echo "Dev Container Audit Report"
echo "==================================="
echo "Period: Last 24 hours"
echo "Location: $AUDIT_LOG_DIR/audit.log"
echo ""

if [ ! -f "$AUDIT_LOG_DIR/audit.log" ]; then
    echo "No audit logs found"
    exit 0
fi

echo "Event Summary:"
echo "  Total events: $(wc -l < "$AUDIT_LOG_DIR/audit.log")"
echo "  File operations: $(grep -c '"event_type":"file_' "$AUDIT_LOG_DIR/audit.log" || echo 0)"
echo "  Network requests: $(grep -c '"event_type":"network_request"' "$AUDIT_LOG_DIR/audit.log" || echo 0)"
echo "  Commands executed: $(grep -c '"event_type":"command_exec"' "$AUDIT_LOG_DIR/audit.log" || echo 0)"
echo "  Git operations: $(grep -c '"event_type":"git_operation"' "$AUDIT_LOG_DIR/audit.log" || echo 0)"
echo ""

echo "Recent Events (last 10):"
tail -10 "$AUDIT_LOG_DIR/audit.log" | jq -r '"\(.timestamp) [\(.event_type)] \(.event_data)"' 2>/dev/null || tail -10 "$AUDIT_LOG_DIR/audit.log"
REPORT

chmod +x /usr/local/bin/audit-report

apt-get clean
rm -rf /var/lib/apt/lists/*

echo "✅ Audit logging installed successfully!"
echo ""
echo "Configuration:"
echo "  Log level: $LOG_LEVEL"
echo "  Retention: $RETENTION_DAYS days"
echo "  SIEM integration: $ENABLE_SIEM"
echo ""
echo "Commands:"
echo "  audit-log <event_type> <data>  - Log custom event"
echo "  audit-report                   - View audit summary"
echo "  cat $AUDIT_DIR/audit.log       - View raw logs"
echo ""
