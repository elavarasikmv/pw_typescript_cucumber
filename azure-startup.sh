#!/bin/bash

# Azure App Service Startup Script for Playwright Cucumber Tests
# This script is optimized for Azure App Service deployment

set -e

echo "=== Azure App Service Playwright Test Runner ==="
echo "Starting at: $(date)"

# Azure App Service specific environment setup
export HEADLESS="true"
export CI="true"
export AZURE_DEPLOYMENT="true"
export PLAYWRIGHT_BROWSERS_PATH="/tmp/playwright-browsers"

# Change to application directory
cd /home/site/wwwroot

# Ensure Node.js modules are installed
echo "Installing dependencies..."
npm ci --only=production

# Install Playwright browsers in a custom location to avoid permission issues
echo "Installing Playwright browsers..."
npx playwright install --with-deps chromium

# Create test results directory
mkdir -p test-results

# Run tests with minimal configuration for Azure
echo "Running tests..."
npm test || {
    echo "Tests completed with some failures. Check logs for details."
    # Don't fail the deployment, just log the issues
}

# Display test results summary
if [ -f "test-results/cucumber-report.json" ]; then
    echo "Test report generated successfully"
    echo "Report location: test-results/cucumber-report.json"
fi

echo "Test execution completed at: $(date)"
echo "==============================================="

# Keep the container running (for web app scenarios)
# Remove this line if you want the container to exit after tests
exec "$@"
