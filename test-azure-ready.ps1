# Azure Playwright Test Script for PowerShell
# This script tests all Playwright endpoints in your Azure App Service

param(
    [Parameter(Mandatory=$true)]
    [string]$AzureAppUrl
)

# Remove trailing slash if present
$AzureAppUrl = $AzureAppUrl.TrimEnd('/')

Write-Host "🚀 Testing Azure Playwright Deployment" -ForegroundColor Green
Write-Host "=======================================" -ForegroundColor Green
Write-Host "App URL: $AzureAppUrl" -ForegroundColor Cyan
Write-Host ""

# Function to make HTTP requests with error handling
function Test-Endpoint {
    param(
        [string]$Endpoint,
        [string]$Method = "GET",
        [string]$Description
    )
    
    Write-Host "🔍 Testing: $Description" -ForegroundColor Yellow
    Write-Host "   URL: $Endpoint"
    
    try {
        $response = Invoke-RestMethod -Uri $Endpoint -Method $Method -TimeoutSec 30
        Write-Host "   ✅ Success!" -ForegroundColor Green
        
        # Pretty print JSON response
        if ($response) {
            $jsonOutput = $response | ConvertTo-Json -Depth 5
            Write-Host "   Response:" -ForegroundColor Gray
            Write-Host $jsonOutput -ForegroundColor Gray
        }
        
        return $true
    }
    catch {
        Write-Host "   ❌ Failed: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
    finally {
        Write-Host ""
    }
}

# Test 1: Health Check
Test-Endpoint -Endpoint "$AzureAppUrl/health" -Method "GET" -Description "Health Check"

# Test 2: Health Check with Browser Test
Test-Endpoint -Endpoint "$AzureAppUrl/health?testBrowser=true" -Method "GET" -Description "Health Check with Browser Test"

# Test 3: Install Browsers
Write-Host "🎭 Installing browsers (this may take a while)..." -ForegroundColor Yellow
try {
    $installResponse = Invoke-WebRequest -Uri "$AzureAppUrl/install-browsers" -Method POST -TimeoutSec 120
    Write-Host "✅ Browser installation completed!" -ForegroundColor Green
    Write-Host $installResponse.Content -ForegroundColor Gray
}
catch {
    Write-Host "❌ Browser installation failed: $($_.Exception.Message)" -ForegroundColor Red
}
Write-Host ""

# Test 4: Web Test
Test-Endpoint -Endpoint "$AzureAppUrl/run-playwright-web" -Method "POST" -Description "Playwright Web Test"

# Test 5: API Test
Test-Endpoint -Endpoint "$AzureAppUrl/run-playwright-api" -Method "POST" -Description "Playwright API Test"

# Test 6: All Tests
Test-Endpoint -Endpoint "$AzureAppUrl/run-playwright-all" -Method "POST" -Description "All Playwright Tests"

Write-Host "🎉 Testing completed!" -ForegroundColor Green
Write-Host ""
Write-Host "📝 Next steps if tests failed:" -ForegroundColor Yellow
Write-Host "1. Check Azure App Service logs in Azure Portal"
Write-Host "2. Verify environment variables are set correctly"
Write-Host "3. Restart the Azure App Service"
Write-Host "4. Run the immediate fix script in Azure SSH console"
