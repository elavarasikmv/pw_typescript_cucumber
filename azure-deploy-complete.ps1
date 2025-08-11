# Azure Playwright Deployment PowerShell Script
# For Windows-based Azure App Service deployments

Write-Host "🚀 Azure Playwright Deployment (PowerShell)" -ForegroundColor Green
Write-Host "=============================================" -ForegroundColor Green

# Set environment variables
$env:AZURE_DEPLOYMENT = "true"
$env:HEADLESS = "true"
$env:CI = "true"
$env:NODE_ENV = "production"
$env:PLAYWRIGHT_BROWSERS_PATH = "D:\home\site\wwwroot\browsers"
$env:PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD = "false"

# Change to application directory
$APP_DIR = "D:\home\site\wwwroot"
if (Test-Path $APP_DIR) {
    Set-Location $APP_DIR
    Write-Host "✅ Changed to Azure App Service directory: $APP_DIR" -ForegroundColor Green
} else {
    Write-Host "⚠️ Not in Azure App Service, using current directory" -ForegroundColor Yellow
}

# Function to log with timestamp
function Write-Log {
    param([string]$Message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Write-Host "[$timestamp] $Message"
}

Write-Log "📋 System Information:"
Write-Log "Node.js version: $(node --version)"
Write-Log "NPM version: $(npm --version)"
Write-Log "Current directory: $(Get-Location)"

# Check if we're in Azure
if ($env:WEBSITE_SITE_NAME) {
    Write-Log "✅ Azure App Service detected: $env:WEBSITE_SITE_NAME"
} else {
    Write-Log "🏠 Not in Azure App Service"
}

# Install dependencies
Write-Log "📦 Installing Node.js dependencies..."
if (Test-Path "package-lock.json") {
    npm ci --production --silent
} else {
    npm install --production --silent
}

# Create browsers directory
Write-Log "📁 Setting up browser directory..."
if (!(Test-Path $env:PLAYWRIGHT_BROWSERS_PATH)) {
    New-Item -ItemType Directory -Path $env:PLAYWRIGHT_BROWSERS_PATH -Force
}

# Install Playwright browsers
Write-Log "🎭 Installing Playwright browsers..."

try {
    & npx playwright install chromium --with-deps
    Write-Log "✅ Standard browser installation successful"
} catch {
    try {
        & npx playwright install chromium
        Write-Log "✅ Browser installation successful (without deps)"
    } catch {
        Write-Log "❌ Browser installation failed: $_"
        try {
            & npm install playwright
            & npx playwright install chromium
            Write-Log "✅ Browser installation successful (with npm install)"
        } catch {
            Write-Log "❌ All browser installation methods failed: $_"
        }
    }
}

# Verify browser installation
Write-Log "🔍 Verifying browser installation..."
try {
    $version = & npx playwright --version
    Write-Log "✅ Playwright CLI is working: $version"
} catch {
    Write-Log "❌ Playwright CLI verification failed: $_"
}

# Test browser launch
Write-Log "🎯 Testing browser launch..."
$testScript = @"
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
    process.exit(1);
  }
})();
"@

try {
    $testScript | node
    Write-Log "✅ Browser launch test passed"
} catch {
    Write-Log "❌ Browser launch test failed: $_"
}

# Set up logging directories
Write-Log "📁 Setting up logging directories..."
@("logs", "test-results", "test-results\screenshots", "test-results\videos") | ForEach-Object {
    if (!(Test-Path $_)) {
        New-Item -ItemType Directory -Path $_ -Force
    }
}

# Start the application
Write-Log "🚀 Starting the application..."
& node server.js
