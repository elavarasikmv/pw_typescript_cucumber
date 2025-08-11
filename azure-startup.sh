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
export PLAYWRIGHT_BROWSERS_PATH="/home/site/wwwroot/browsers"
export PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD=false

# Change to application directory
cd /home/site/wwwroot

# Check Node.js version
echo "Node.js version: $(node --version)"
echo "NPM version: $(npm --version)"

# Ensure Node.js modules are installed
echo "Installing dependencies..."
if [ -f "package-lock.json" ]; then
    npm ci --production --silent
else
    npm install --production --silent
fi

# Install Playwright browsers if not already installed
echo "🎭 Checking Playwright browser installation..."
if ! npx playwright --version > /dev/null 2>&1; then
    echo "❌ Playwright not found, installing..."
    npm install playwright
fi

# Install browsers
echo "🚀 Installing Playwright browsers..."
npx playwright install --with-deps chromium || {
    echo "⚠️ Standard installation failed, trying alternative method..."
    npx playwright install chromium
}

# Verify browser installation
echo "🔍 Verifying browser installation..."
node -e "
const { chromium } = require('playwright');
(async () => {
  try {
    console.log('Testing browser launch...');
    const browser = await chromium.launch({ 
      headless: true,
      args: ['--no-sandbox', '--disable-dev-shm-usage', '--disable-gpu']
    });
    console.log('✅ Browser launched successfully');
    await browser.close();
  } catch (error) {
    console.error('❌ Browser test failed:', error.message);
    console.log('🔧 Available browsers:', await chromium.executablePath());
  }
})();
" || echo "⚠️ Browser verification failed, continuing anyway..."

# Install Playwright browsers in a custom location to avoid permission issues
echo "Installing Playwright browsers..."
export PLAYWRIGHT_BROWSERS_PATH=/tmp/playwright-browsers
mkdir -p $PLAYWRIGHT_BROWSERS_PATH

# Install only Chromium to save space and time
npx playwright install chromium --with-deps || {
    echo "Failed to install Playwright browsers, trying alternative method..."
    npx playwright install-deps
    npx playwright install chromium
}

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
