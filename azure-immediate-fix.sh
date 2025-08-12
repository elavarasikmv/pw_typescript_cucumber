#!/bin/bash

# IMMEDIATE FIX SCRIPT FOR AZURE APP SERVICE
# Run this in Azure App Service SSH console to fix browser issues immediately

echo "🚨 IMMEDIATE AZURE PLAYWRIGHT FIX"
echo "================================="

# Step 1: Set correct environment variables
echo "📋 Setting environment variables..."
export PLAYWRIGHT_BROWSERS_PATH="/home/site/wwwroot/browsers"
export PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD="false"
export PLAYWRIGHT_CACHE_DIR="/home/site/wwwroot/.cache"

# Step 2: Create directories
echo "📁 Creating directories..."
mkdir -p /home/site/wwwroot/browsers
mkdir -p /home/site/wwwroot/.cache
chmod 755 /home/site/wwwroot/browsers
chmod 755 /home/site/wwwroot/.cache

# Step 3: Change to app directory
cd /home/site/wwwroot

# Step 4: Remove old browser installations
echo "🧹 Cleaning old installations..."
rm -rf /tmp/playwright-browsers/* 2>/dev/null || true
rm -rf ~/.cache/ms-playwright/* 2>/dev/null || true

# Step 5: Install Playwright and browsers
echo "📦 Installing Playwright..."
npm install playwright --save

echo "🎭 Installing browsers..."
npx playwright install chromium --with-deps

# Step 6: Verify installation
echo "🔍 Verifying installation..."
npx playwright --version

# Step 7: Test browser launch
echo "🎯 Testing browser..."
node -e "
const { chromium } = require('playwright');
(async () => {
  try {
    console.log('🚀 Testing browser launch...');
    console.log('Executable path:', chromium.executablePath());
    
    const browser = await chromium.launch({ 
      headless: true,
      args: ['--no-sandbox', '--disable-dev-shm-usage', '--disable-gpu']
    });
    
    console.log('✅ Browser launched successfully!');
    await browser.close();
    console.log('✅ Fix completed successfully!');
    
  } catch (error) {
    console.error('❌ Browser test failed:', error.message);
    console.log('');
    console.log('🔧 Manual steps to try:');
    console.log('1. Restart the Azure App Service');
    console.log('2. Check if all environment variables are set in Azure Portal');
    console.log('3. Redeploy the application');
  }
})();
"

echo ""
echo "✅ Fix script completed!"
echo "📝 Next steps:"
echo "1. Restart your Azure App Service"
echo "2. Test the /run-playwright-all endpoint"
echo "3. If still failing, check Azure Portal application settings"
