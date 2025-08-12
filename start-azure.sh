#!/bin/bash

# Azure App Service Environment Setup Script
# This script ensures proper environment variables are set before starting the application

echo "🚀 Azure Environment Setup"
echo "=========================="

# Force correct environment variables for Azure App Service
export PLAYWRIGHT_BROWSERS_PATH="/home/site/wwwroot/browsers"
export PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD="false"
export PLAYWRIGHT_CACHE_DIR="/home/site/wwwroot/.cache"
export HEADLESS="true"
export CI="true"
export NODE_ENV="production"

# Create directories
mkdir -p /home/site/wwwroot/browsers
mkdir -p /home/site/wwwroot/.cache
mkdir -p /home/site/wwwroot/logs
mkdir -p /home/site/wwwroot/test-results

# Set permissions
chmod 755 /home/site/wwwroot/browsers
chmod 755 /home/site/wwwroot/.cache

echo "📋 Environment Variables Set:"
echo "PLAYWRIGHT_BROWSERS_PATH=$PLAYWRIGHT_BROWSERS_PATH"
echo "PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD=$PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD"
echo "PLAYWRIGHT_CACHE_DIR=$PLAYWRIGHT_CACHE_DIR"
echo "HEADLESS=$HEADLESS"
echo "CI=$CI"
echo "NODE_ENV=$NODE_ENV"

# Change to application directory
cd /home/site/wwwroot

# Install browsers immediately
echo "🎭 Installing browsers with correct paths..."
npx playwright install chromium --with-deps || {
    echo "⚠️ Standard installation failed, trying alternative..."
    npx playwright install chromium
}

# Verify installation
echo "🔍 Verifying browser installation..."
node -e "
const { chromium } = require('playwright');
(async () => {
  try {
    console.log('Browser executable path:', chromium.executablePath());
    const browser = await chromium.launch({ headless: true, args: ['--no-sandbox'] });
    console.log('✅ Browser test successful');
    await browser.close();
  } catch (error) {
    console.error('❌ Browser test failed:', error.message);
  }
})();
"

# Start the application with correct environment
echo "🚀 Starting application..."
exec node server.js
