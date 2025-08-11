#!/bin/bash

# Azure Browser Installation Script for Playwright
# This script ensures Playwright browsers are properly installed in Azure App Service

echo "🎭 Starting Azure Playwright Browser Installation..."
echo "================================================="

# Set environment variables
export PLAYWRIGHT_BROWSERS_PATH=/home/site/wwwroot/browsers
export PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD=false

# Create browsers directory
mkdir -p /home/site/wwwroot/browsers

# Check if we're in Azure App Service
if [ -d "/home/site/wwwroot" ]; then
    echo "✅ Azure App Service environment detected"
    cd /home/site/wwwroot
else
    echo "🏠 Local environment detected"
fi

# Check Node.js version
echo "📋 Node.js version: $(node --version)"
echo "📋 NPM version: $(npm --version)"

# Install Playwright browsers
echo "🚀 Installing Playwright browsers..."
npx playwright install --with-deps chromium

# Verify installation
echo "🔍 Verifying browser installation..."
if npx playwright --version; then
    echo "✅ Playwright CLI is working"
else
    echo "❌ Playwright CLI failed"
    exit 1
fi

# Test browser availability
echo "🎯 Testing browser availability..."
node -e "
const { chromium } = require('playwright');
(async () => {
  try {
    const browser = await chromium.launch({ headless: true });
    console.log('✅ Chromium browser launched successfully');
    await browser.close();
    console.log('✅ Browser test completed');
  } catch (error) {
    console.error('❌ Browser test failed:', error.message);
    process.exit(1);
  }
})();
"

echo "🎉 Browser installation completed successfully!"
echo "================================================="
