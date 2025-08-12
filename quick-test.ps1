# Quick Azure Playwright Test Script
# Usage: .\quick-test.ps1 "https://your-app.azurewebsites.net"

param(
    [string]$AppUrl = ""
)

if (-not $AppUrl) {
    $AppUrl = Read-Host "Enter your Azure App Service URL (e.g., https://your-app.azurewebsites.net)"
}

$AppUrl = $AppUrl.TrimEnd('/')

Write-Host "🎭 Quick Playwright Test for: $AppUrl" -ForegroundColor Cyan

# Test 1: Quick health check
try {
    $health = Invoke-RestMethod -Uri "$AppUrl/health" -TimeoutSec 10
    Write-Host "✅ App is healthy: $($health.status)" -ForegroundColor Green
} catch {
    Write-Host "❌ Health check failed: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Test 2: Run all tests
Write-Host "🚀 Running all Playwright tests..." -ForegroundColor Yellow
try {
    $result = Invoke-RestMethod -Uri "$AppUrl/run-playwright-all" -Method POST -TimeoutSec 60
    
    if ($result.success) {
        Write-Host "🎉 ALL TESTS PASSED!" -ForegroundColor Green
        Write-Host "Web Test: $($result.results.webTest.success)" -ForegroundColor Green
        Write-Host "API Test: $($result.results.apiTest.success)" -ForegroundColor Green
    } else {
        Write-Host "❌ SOME TESTS FAILED" -ForegroundColor Red
        Write-Host "Web Test: $($result.results.webTest.success) - $($result.results.webTest.error)" -ForegroundColor Red
        Write-Host "API Test: $($result.results.apiTest.success) - $($result.results.apiTest.error)" -ForegroundColor Red
        
        # If web test failed due to browser issues, try to install browsers
        if ($result.results.webTest.error -like "*Executable doesn't exist*") {
            Write-Host "🔧 Detected browser issue, attempting to install browsers..." -ForegroundColor Yellow
            try {
                Invoke-WebRequest -Uri "$AppUrl/install-browsers" -Method POST -TimeoutSec 120 | Out-Null
                Write-Host "✅ Browsers installed, please try running tests again" -ForegroundColor Green
            } catch {
                Write-Host "❌ Browser installation failed: $($_.Exception.Message)" -ForegroundColor Red
            }
        }
    }
    
    # Show full response
    Write-Host "`n📊 Full Response:" -ForegroundColor Gray
    $result | ConvertTo-Json -Depth 5 | Write-Host -ForegroundColor Gray
    
} catch {
    Write-Host "❌ Test execution failed: $($_.Exception.Message)" -ForegroundColor Red
    
    # Try browser installation as fallback
    Write-Host "🔧 Attempting browser installation as fallback..." -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "$AppUrl/install-browsers" -Method POST -TimeoutSec 60 | Out-Null
        Write-Host "✅ Browser installation attempt completed" -ForegroundColor Green
    } catch {
        Write-Host "❌ Browser installation also failed" -ForegroundColor Red
    }
}

Write-Host "`n📝 Manual testing URLs:" -ForegroundColor Cyan
Write-Host "Health: $AppUrl/health"
Write-Host "Browser Test: $AppUrl/health?testBrowser=true"
Write-Host "Install Browsers: $AppUrl/install-browsers (POST)"
Write-Host "All Tests: $AppUrl/run-playwright-all (POST)"
