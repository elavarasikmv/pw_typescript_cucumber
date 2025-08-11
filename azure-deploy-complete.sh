#!/bin/bash

# Comprehensive Azure Deployment Script for Playwright
# This script handles all aspects of Playwright deployment in Azure App Service

echo "🚀 Azure Playwright Deployment Script"
echo "====================================="
echo "Time: $(date)"

# Set strict mode
set -euo pipefail

# Azure environment variables
export AZURE_DEPLOYMENT="true"
export HEADLESS="true"
export CI="true"
export NODE_ENV="production"
export PLAYWRIGHT_BROWSERS_PATH="/home/site/wwwroot/browsers"
export PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD="false"

# Change to application directory
APP_DIR="/home/site/wwwroot"
if [ -d "$APP_DIR" ]; then
    cd "$APP_DIR"
    echo "✅ Changed to Azure App Service directory: $APP_DIR"
else
    echo "⚠️ Not in Azure App Service, using current directory"
fi

# Function to log with timestamp
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

# Function to check command availability
check_command() {
    if command -v "$1" >/dev/null 2>&1; then
        log "✅ $1 is available"
        return 0
    else
        log "❌ $1 is not available"
        return 1
    fi
}

# System information
log "📋 System Information:"
log "Node.js version: $(node --version)"
log "NPM version: $(npm --version)"
log "OS: $(uname -a)"
log "Current directory: $(pwd)"
log "User: $(whoami)"

# Check if we're in Azure
if [ ! -z "${WEBSITE_SITE_NAME:-}" ]; then
    log "✅ Azure App Service detected: $WEBSITE_SITE_NAME"
else
    log "🏠 Not in Azure App Service"
fi

# Install dependencies
log "📦 Installing Node.js dependencies..."
if [ -f "package-lock.json" ]; then
    npm ci --production --silent
else
    npm install --production --silent
fi

# Create browsers directory
log "📁 Setting up browser directory..."
mkdir -p "$PLAYWRIGHT_BROWSERS_PATH"
chmod 755 "$PLAYWRIGHT_BROWSERS_PATH"

# Install system dependencies (if we have permissions)
log "🔧 Checking system dependencies..."
if check_command "apt-get"; then
    log "📥 Installing system dependencies..."
    apt-get update -qq && apt-get install -y -qq \
        libnss3 \
        libatk-bridge2.0-0 \
        libdrm2 \
        libxkbcommon0 \
        libxcomposite1 \
        libxdamage1 \
        libxrandr2 \
        libgbm1 \
        libxss1 \
        libasound2 \
        || log "⚠️ Could not install system dependencies (permissions)"
fi

# Install Playwright browsers
log "🎭 Installing Playwright browsers..."

# Method 1: Standard installation
if npx playwright install chromium --with-deps; then
    log "✅ Standard browser installation successful"
elif npx playwright install chromium; then
    log "✅ Browser installation successful (without deps)"
elif npm install playwright && npx playwright install chromium; then
    log "✅ Browser installation successful (with npm install)"
else
    log "❌ All browser installation methods failed"
    log "🔧 Attempting manual browser setup..."
    
    # Method 2: Manual browser download
    CHROMIUM_URL="https://playwright.azureedge.net/builds/chromium/1091/chromium-linux.zip"
    BROWSER_DIR="$PLAYWRIGHT_BROWSERS_PATH/chromium-1091"
    
    mkdir -p "$BROWSER_DIR"
    if command -v wget >/dev/null 2>&1; then
        wget -q "$CHROMIUM_URL" -O /tmp/chromium.zip
        unzip -q /tmp/chromium.zip -d "$BROWSER_DIR"
        chmod +x "$BROWSER_DIR"/chrome-linux/chrome
        log "✅ Manual browser installation completed"
    else
        log "❌ Manual browser installation failed - wget not available"
    fi
fi

# Verify browser installation
log "🔍 Verifying browser installation..."
if npx playwright --version >/dev/null 2>&1; then
    log "✅ Playwright CLI is working"
    npx playwright --version
else
    log "❌ Playwright CLI verification failed"
fi

# Test browser launch
log "🎯 Testing browser launch..."
node -e "
const { chromium } = require('playwright');
(async () => {
  try {
    console.log('🚀 Attempting to launch browser...');
    const browser = await chromium.launch({ 
      headless: true,
      args: [
        '--no-sandbox',
        '--disable-dev-shm-usage',
        '--disable-gpu',
        '--no-first-run',
        '--no-zygote',
        '--single-process'
      ]
    });
    console.log('✅ Browser launched successfully');
    console.log('📍 Executable path:', chromium.executablePath());
    await browser.close();
    console.log('✅ Browser test completed successfully');
  } catch (error) {
    console.error('❌ Browser test failed:', error.message);
    console.log('🔧 Available executable paths:');
    try {
      console.log('Chromium path:', chromium.executablePath());
    } catch (e) {
      console.log('Cannot determine executable path:', e.message);
    }
    process.exit(1);
  }
})();
" && log "✅ Browser launch test passed" || log "❌ Browser launch test failed"

# Set up logging directories
log "📁 Setting up logging directories..."
mkdir -p logs test-results/screenshots test-results/videos

# Start the application
log "🚀 Starting the application..."
exec node server.js
