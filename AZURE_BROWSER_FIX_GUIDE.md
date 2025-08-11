# Azure Playwright Browser Installation Fix Guide

## Problem
When running Playwright tests in Azure App Service, you get the error:
```
browserType.launch: Executable doesn't exist at /tmp/playwright-browsers/chromium_headless_shell-1181/chrome-linux/headless_shell
```

## Root Cause
- Playwright browsers are not installed in the Azure App Service container
- Browser dependencies are missing
- Incorrect browser paths in Azure environment

## Solutions Applied

### 1. Updated Package.json Scripts
Added Azure-specific browser installation scripts:
```json
{
  "scripts": {
    "prestart": "npm run install-browsers-docker",
    "postinstall": "npm run install-browsers-docker",
    "install-browsers-docker": "npx playwright install chromium --with-deps",
    "azure:install": "npx playwright install chromium --with-deps && npx playwright install-deps",
    "azure:test": "npm run azure:install && npm test"
  }
}
```

### 2. Enhanced Dockerfile
- Updated base image to include system dependencies
- Added comprehensive browser installation
- Set proper environment variables
- Added health checks

### 3. Azure Deployment Scripts
Created multiple deployment scripts:
- `azure-deploy-complete.sh` - Comprehensive Linux deployment
- `azure-deploy-complete.ps1` - Windows deployment alternative
- `azure-browser-install.sh` - Dedicated browser installation

### 4. Enhanced Test Files
Updated `basic-web-test.js` to:
- Check browser availability before running tests
- Automatically install browsers if missing
- Provide better error messages
- Include fallback mechanisms

### 5. Azure App Service Configuration
- Added `web.config` for IIS node configuration
- Set proper environment variables
- Configured browser paths for Azure

## Manual Installation Commands

If automatic installation fails, run these commands in Azure App Service Console:

### For Linux App Service:
```bash
cd /home/site/wwwroot
npm install playwright
npx playwright install chromium --with-deps
npx playwright install-deps
```

### For Windows App Service:
```powershell
cd D:\home\site\wwwroot
npm install playwright
npx playwright install chromium --with-deps
```

## Environment Variables to Set in Azure

Add these in Azure Portal → App Service → Configuration → Application Settings:

```
PLAYWRIGHT_BROWSERS_PATH=/home/site/wwwroot/browsers
PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD=false
HEADLESS=true
CI=true
NODE_ENV=production
```

## Testing the Fix

1. Deploy the updated application
2. Navigate to your app URL
3. Click "Run All Tests"
4. Check the logs for browser installation progress

## Alternative Solutions

### Option 1: Use Azure Container Instances
If App Service continues to have issues, consider Azure Container Instances with Docker.

### Option 2: Serverless with Azure Functions
For simpler tests, consider Azure Functions with headless browser support.

### Option 3: Azure DevOps Pipeline
Run tests in Azure DevOps with proper Playwright setup.

## Monitoring

Monitor the following logs:
- Application logs in Azure Portal
- Browser installation logs
- Test execution logs
- Health check status

## Support Commands

```bash
# Check browser installation
npx playwright --version

# List installed browsers
npx playwright install --dry-run

# Test browser launch
node -e "const {chromium} = require('playwright'); chromium.launch().then(() => console.log('OK'))"

# Check executable path
node -e "const {chromium} = require('playwright'); console.log(chromium.executablePath())"
```

## Success Indicators

✅ Application starts without errors
✅ Browser installation completes successfully
✅ Health check passes
✅ Web tests run successfully
✅ API tests continue to work

The fixes implemented should resolve the browser installation issue and make your Playwright tests work reliably in Azure App Service.
