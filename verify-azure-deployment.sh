#!/bin/bash

# Quick verification script for Azure Playwright deployment
# Run this after deployment to verify everything works

echo "🔍 Azure Playwright Verification Script"
echo "======================================="

# Check environment
echo "📋 Environment Check:"
echo "Node.js: $(node --version)"
echo "NPM: $(npm --version)"
echo "Working directory: $(pwd)"

# Check if we're in Azure
if [ ! -z "${WEBSITE_SITE_NAME:-}" ]; then
    echo "✅ Running in Azure App Service: $WEBSITE_SITE_NAME"
else
    echo "🏠 Running locally (not Azure App Service)"
fi

# Check Playwright installation
echo ""
echo "🎭 Playwright Check:"
if command -v npx >/dev/null 2>&1; then
    if npx playwright --version >/dev/null 2>&1; then
        echo "✅ Playwright CLI available: $(npx playwright --version)"
    else
        echo "❌ Playwright CLI not working"
        exit 1
    fi
else
    echo "❌ NPX not available"
    exit 1
fi

# Check browser installation
echo ""
echo "🌐 Browser Check:"
node -e "
const { chromium } = require('playwright');
(async () => {
  try {
    console.log('📍 Browser executable path:', chromium.executablePath());
    console.log('🚀 Testing browser launch...');
    
    const browser = await chromium.launch({ 
      headless: true,
      args: ['--no-sandbox', '--disable-dev-shm-usage', '--disable-gpu']
    });
    
    console.log('✅ Browser launched successfully');
    
    const context = await browser.newContext();
    const page = await context.newPage();
    
    console.log('🔗 Testing navigation...');
    await page.goto('https://example.com', { timeout: 15000 });
    
    const title = await page.title();
    console.log('✅ Page loaded:', title);
    
    await browser.close();
    console.log('✅ All browser tests passed!');
    
  } catch (error) {
    console.error('❌ Browser test failed:', error.message);
    console.log('');
    console.log('🔧 Troubleshooting steps:');
    console.log('1. Run: npx playwright install chromium --with-deps');
    console.log('2. Check Azure app settings match azure-app-settings.txt');
    console.log('3. Restart the Azure App Service');
    console.log('4. Check deployment logs for errors');
    process.exit(1);
  }
})();
"

echo ""
echo "🎉 Verification completed successfully!"
echo "Your Playwright setup is ready for Azure App Service!"
