#!/bin/bash

# Azure Log Monitoring Script
# This script helps monitor logs in Azure App Service

echo "=== Playwright Cucumber Log Monitor ==="
echo "Starting log monitoring at: $(date)"

# Create logs directory if it doesn't exist
mkdir -p /home/site/wwwroot/logs
mkdir -p /home/LogFiles

# Function to tail and display logs
monitor_logs() {
    echo "📊 Monitoring application logs..."
    
    # Monitor application logs
    if [ -f "/home/site/wwwroot/logs/application-$(date +%Y-%m-%d).log" ]; then
        echo "📋 Latest Application Logs:"
        tail -n 20 "/home/site/wwwroot/logs/application-$(date +%Y-%m-%d).log"
    fi
    
    # Monitor test execution logs
    if [ -f "/home/site/wwwroot/logs/test-execution-$(date +%Y-%m-%d).log" ]; then
        echo "📋 Latest Test Execution Logs:"
        tail -n 20 "/home/site/wwwroot/logs/test-execution-$(date +%Y-%m-%d).log"
    fi
    
    # Monitor error logs
    if [ -f "/home/site/wwwroot/logs/error-$(date +%Y-%m-%d).log" ]; then
        echo "❌ Latest Error Logs:"
        tail -n 10 "/home/site/wwwroot/logs/error-$(date +%Y-%m-%d).log"
    fi
    
    # Monitor Azure logs
    if [ -f "/home/LogFiles/nodejs_stdout.log" ]; then
        echo "🔷 Azure stdout logs:"
        tail -n 10 "/home/LogFiles/nodejs_stdout.log"
    fi
    
    if [ -f "/home/LogFiles/nodejs_stderr.log" ]; then
        echo "🔷 Azure stderr logs:"
        tail -n 10 "/home/LogFiles/nodejs_stderr.log"
    fi
}

# Function to clean old logs
cleanup_logs() {
    echo "🧹 Cleaning up old logs..."
    
    # Remove logs older than 7 days
    find /home/site/wwwroot/logs -name "*.log" -mtime +7 -delete 2>/dev/null || true
    
    # Compress logs older than 1 day
    find /home/site/wwwroot/logs -name "*.log" -mtime +1 -exec gzip {} \; 2>/dev/null || true
    
    echo "✅ Log cleanup completed"
}

# Function to create log summary
create_summary() {
    echo "📊 Creating log summary..."
    
    SUMMARY_FILE="/home/site/wwwroot/logs/summary-$(date +%Y-%m-%d).txt"
    
    cat > "$SUMMARY_FILE" << EOF
Playwright Cucumber Test Summary
================================
Date: $(date)
Environment: ${NODE_ENV:-production}
Browser: ${BROWSER:-chromium}
Headless: ${HEADLESS:-true}

Log Files Available:
EOF
    
    ls -la /home/site/wwwroot/logs/*.log 2>/dev/null >> "$SUMMARY_FILE" || echo "No log files found" >> "$SUMMARY_FILE"
    
    echo "Summary created: $SUMMARY_FILE"
}

# Main execution
case "${1:-monitor}" in
    "monitor")
        monitor_logs
        ;;
    "cleanup")
        cleanup_logs
        ;;
    "summary")
        create_summary
        ;;
    "all")
        monitor_logs
        cleanup_logs
        create_summary
        ;;
    *)
        echo "Usage: $0 [monitor|cleanup|summary|all]"
        echo "  monitor  - Display recent logs"
        echo "  cleanup  - Clean old logs"
        echo "  summary  - Create log summary"
        echo "  all      - Run all operations"
        ;;
esac

echo "=== Log monitoring completed ==="
