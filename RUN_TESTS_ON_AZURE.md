# Azure Playwright Testing Guide

## 🎯 Testing Steps for Azure App Service

### Prerequisites
1. Ensure your code is deployed to Azure App Service
2. Have your Azure App Service URL ready (e.g., `https://your-app-name.azurewebsites.net`)

### Method 1: Using Web Browser (Easiest)

#### Step 1: Access Your Application
```
https://your-app-name.azurewebsites.net
```

#### Step 2: Test Health Check
```
https://your-app-name.azurewebsites.net/health
```
Expected: JSON response with status "healthy"

#### Step 3: Test Health Check with Browser Verification
```
https://your-app-name.azurewebsites.net/health?testBrowser=true
```
Expected: JSON response showing Playwright status

#### Step 4: Access Test Interface (New!)
```
https://your-app-name.azurewebsites.net/test-interface.html
```
Expected: Interactive web interface with buttons to run tests

#### Step 5: Open Developer Tools and Test Endpoints
Press F12 → Console tab, then run:

```javascript
// Test browser installation
fetch('/install-browsers', { method: 'POST' })
  .then(response => response.text())
  .then(data => console.log(data));

// Check browser status
fetch('/check-browser', { method: 'POST' })
  .then(response => response.json())
  .then(data => console.log(data));

// Test web test
fetch('/run-playwright-web', { method: 'POST' })
  .then(response => response.json())
  .then(data => console.log(data));

// Test API test
fetch('/run-playwright-api', { method: 'POST' })
  .then(response => response.json())
  .then(data => console.log(data));

// Test all tests
fetch('/run-playwright-all', { method: 'POST' })
  .then(response => response.json())
  .then(data => console.log(data));

// Test Cucumber tests
fetch('/run-tests', { method: 'POST' })
  .then(response => response.text())
  .then(data => console.log(data));
```

### Method 2: Using PowerShell/Command Line

#### Check browser status:
```powershell
$uri = "https://your-app-name.azurewebsites.net/check-browser"
$response = Invoke-RestMethod -Uri $uri -Method POST
$response | ConvertTo-Json -Depth 5
```

#### Install browsers first:
```powershell
$uri = "https://your-app-name.azurewebsites.net/install-browsers"
Invoke-RestMethod -Uri $uri -Method POST
```

#### Test web test:
```powershell
$uri = "https://your-app-name.azurewebsites.net/run-playwright-web"
$response = Invoke-RestMethod -Uri $uri -Method POST
$response | ConvertTo-Json -Depth 5
```

#### Test API test:
```powershell
$uri = "https://your-app-name.azurewebsites.net/run-playwright-api"
$response = Invoke-RestMethod -Uri $uri -Method POST
$response | ConvertTo-Json -Depth 5
```

#### Test all tests:
```powershell
$uri = "https://your-app-name.azurewebsites.net/run-playwright-all"
$response = Invoke-RestMethod -Uri $uri -Method POST
$response | ConvertTo-Json -Depth 5
```

### Method 3: Using curl

#### Test browser installation:
```bash
curl -X POST https://your-app-name.azurewebsites.net/install-browsers
```

#### Test web test:
```bash
curl -X POST https://your-app-name.azurewebsites.net/run-playwright-web \
  -H "Content-Type: application/json" | jq '.'
```

#### Test all tests:
```bash
curl -X POST https://your-app-name.azurewebsites.net/run-playwright-all \
  -H "Content-Type: application/json" | jq '.'
```

### Method 4: Using Postman

1. Open Postman
2. Create new request
3. Set method to POST
4. Set URL to: `https://your-app-name.azurewebsites.net/run-playwright-all`
5. Click Send
6. Check response

### 📊 Expected Test Results

#### ✅ Success Response:
```json
{
  "success": true,
  "results": {
    "webTest": {
      "success": true,
      "message": "Basic web test passed",
      "details": {
        "title": "Example Domain",
        "url": "https://example.com/",
        "loadTime": 1500,
        "exampleTextVisible": true
      }
    },
    "apiTest": {
      "success": true,
      "message": "API test passed",
      "details": {
        "getStatus": 200,
        "postStatus": 201,
        "totalPosts": 100
      }
    }
  },
  "message": "All Playwright tests executed",
  "timestamp": "2025-08-11T23:55:31.980Z"
}
```

#### ❌ Error Response (Browser Not Installed):
```json
{
  "success": false,
  "results": {
    "webTest": {
      "success": false,
      "error": "Browser installation issue detected",
      "instruction": "Please run: npx playwright install chromium --with-deps"
    }
  }
}
```

### 🛠 Troubleshooting Steps

If tests fail:

1. **Run browser installation endpoint first:**
   ```
   POST /install-browsers
   ```

2. **Check Azure Console Logs:**
   - Go to Azure Portal → App Service → Log stream
   - Look for browser installation messages

3. **Check Application Settings:**
   - Azure Portal → App Service → Configuration
   - Ensure these are set:
     - `PLAYWRIGHT_BROWSERS_PATH=/home/site/wwwroot/browsers`
     - `PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD=false`

4. **Restart App Service:**
   - Azure Portal → App Service → Restart

5. **Manual Fix in Azure SSH Console:**
   ```bash
   cd /home/site/wwwroot
   ./azure-immediate-fix.sh
   ```

### 🔍 Monitoring

Monitor these logs during testing:
- Application logs in Azure Portal
- Health check responses
- Console output in browser developer tools

### 📝 Test Sequence

Recommended testing order:
1. Health check
2. Install browsers
3. Test web test
4. Test API test  
5. Test all tests

This ensures each component works before running the full suite.
