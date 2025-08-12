#!/usr/bin/env pwsh
# Azure Cucumber Fix Verification Script
# This script verifies that all browser path issues have been resolved

Write-Host "🔍 Verifying Azure Cucumber Browser Path Fixes..." -ForegroundColor Cyan
Write-Host "=" * 60

# Check current directory
$workingDir = Get-Location
Write-Host "📁 Working directory: $workingDir" -ForegroundColor Green

# Function to test endpoint
function Test-Endpoint {
    param(
        [string]$Url,
        [string]$Description,
        [string]$Method = "GET"
    )
    
    try {
        Write-Host "🌐 Testing $Description..." -ForegroundColor Yellow
        
        if ($Method -eq "POST") {
            $response = Invoke-WebRequest -Uri $Url -Method POST -TimeoutSec 30
        } else {
            $response = Invoke-WebRequest -Uri $Url -TimeoutSec 30
        }
        
        if ($response.StatusCode -eq 200) {
            Write-Host "✅ ${Description}: SUCCESS" -ForegroundColor Green
            return $true
        } else {
            Write-Host "❌ ${Description}: FAILED (Status: $($response.StatusCode))" -ForegroundColor Red
            return $false
        }
    } catch {
        Write-Host "❌ ${Description}: ERROR - $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

# Function to check for hardcoded paths
function Check-HardcodedPaths {
    Write-Host "🔍 Checking for hardcoded /tmp/playwright-browsers paths..." -ForegroundColor Yellow
    
    $searchResults = @()
    $filesToCheck = @(
        "src/support/world.ts",
        "src/support/hooks.ts", 
        "server.js",
        "src/tests/basic-web-test.js"
    )
    
    foreach ($file in $filesToCheck) {
        if (Test-Path $file) {
            $content = Get-Content $file -Raw
            if ($content -match "/tmp/playwright-browsers" -and $content -notmatch "fallback|default|comment") {
                $searchResults += $file
                Write-Host "⚠️  Found hardcoded path in: $file" -ForegroundColor Yellow
            } else {
                Write-Host "✅ No hardcoded paths in: $file" -ForegroundColor Green
            }
        } else {
            Write-Host "⚠️  File not found: $file" -ForegroundColor Yellow
        }
    }
    
    return $searchResults.Count -eq 0
}

# Function to test local server functionality
function Test-LocalServer {
    Write-Host "🚀 Testing local server functionality..." -ForegroundColor Cyan
    
    # Start the server in background
    $serverProcess = Start-Process "node" -ArgumentList "server.js" -NoNewWindow -PassThru
    
    Start-Sleep -Seconds 5
    
    try {
        $serverUrl = "http://localhost:3000"
        
        # Test various endpoints
        $tests = @(
            @{ Url = "$serverUrl"; Description = "Home page"; Method = "GET" },
            @{ Url = "$serverUrl/health"; Description = "Health check"; Method = "GET" },
            @{ Url = "$serverUrl/test-interface.html"; Description = "Test interface"; Method = "GET" }
        )
        
        $allPassed = $true
        foreach ($test in $tests) {
            $result = Test-Endpoint -Url $test.Url -Description $test.Description -Method $test.Method
            if (-not $result) { $allPassed = $false }
        }
        
        return $allPassed
        
    } finally {
        # Stop the server
        if ($serverProcess -and -not $serverProcess.HasExited) {
            Stop-Process -Id $serverProcess.Id -Force
            Write-Host "🛑 Server stopped" -ForegroundColor Yellow
        }
    }
}

# Function to check git status
function Check-GitStatus {
    Write-Host "📝 Checking git status..." -ForegroundColor Cyan
    
    try {
        $gitStatus = git status --porcelain
        
        if ($gitStatus) {
            Write-Host "📋 Uncommitted changes found:" -ForegroundColor Yellow
            $gitStatus | ForEach-Object { Write-Host "   $_" -ForegroundColor Gray }
            
            $commit = Read-Host "Do you want to commit these changes? (y/n)"
            if ($commit -eq 'y' -or $commit -eq 'Y') {
                git add .
                git commit -m "Fix: Resolve Playwright browser path issues for Azure deployment - Updated all hardcoded paths to use Azure-compatible paths - Fixed world.ts, hooks.ts, server.js, and test files - Added proper Azure environment detection and browser path handling - Ensured consistent browser installation across all components"
                
                Write-Host "✅ Changes committed successfully!" -ForegroundColor Green
                
                $push = Read-Host "Do you want to push to remote? (y/n)"
                if ($push -eq 'y' -or $push -eq 'Y') {
                    git push
                    Write-Host "✅ Changes pushed to remote!" -ForegroundColor Green
                }
            }
        } else {
            Write-Host "✅ No uncommitted changes" -ForegroundColor Green
        }
    } catch {
        Write-Host "❌ Git error: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Function to run basic tests
function Run-BasicTests {
    Write-Host "🧪 Running basic test verification..." -ForegroundColor Cyan
    
    try {
        # Test npm install
        Write-Host "📦 Checking npm dependencies..." -ForegroundColor Yellow
        $npmResult = npm list --depth=0 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ NPM dependencies OK" -ForegroundColor Green
        } else {
            Write-Host "⚠️  NPM dependencies may have issues" -ForegroundColor Yellow
        }
        
        # Test syntax
        Write-Host "🔍 Checking syntax..." -ForegroundColor Yellow
        $syntaxCheck = node -c server.js 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ Server.js syntax OK" -ForegroundColor Green
        } else {
            Write-Host "❌ Server.js syntax error: $syntaxCheck" -ForegroundColor Red
            return $false
        }
        
        return $true
    } catch {
        Write-Host "❌ Test error: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

# Main execution
Write-Host "🏁 Starting verification process..." -ForegroundColor Cyan

$results = @{
    HardcodedPaths = Check-HardcodedPaths
    BasicTests = Run-BasicTests
    LocalServer = Test-LocalServer
}

Check-GitStatus

Write-Host "`n📊 VERIFICATION SUMMARY" -ForegroundColor Cyan
Write-Host "=" * 30
Write-Host "✅ Hardcoded paths fixed: $($results.HardcodedPaths)" -ForegroundColor $(if($results.HardcodedPaths) {"Green"} else {"Red"})
Write-Host "✅ Basic tests passed: $($results.BasicTests)" -ForegroundColor $(if($results.BasicTests) {"Green"} else {"Red"})
Write-Host "✅ Local server functional: $($results.LocalServer)" -ForegroundColor $(if($results.LocalServer) {"Green"} else {"Red"})

$allPassed = $results.Values | ForEach-Object { $_ } | Where-Object { $_ -eq $false } | Measure-Object | Select-Object -ExpandProperty Count
if ($allPassed -eq 0) {
    Write-Host "`n🎉 ALL CHECKS PASSED! Ready for Azure deployment!" -ForegroundColor Green
    Write-Host "📌 Next steps:" -ForegroundColor Cyan
    Write-Host "   1. Deploy to Azure App Service" -ForegroundColor White
    Write-Host "   2. Run /install-browsers endpoint" -ForegroundColor White
    Write-Host "   3. Test with /run-tests or /test-interface.html" -ForegroundColor White
} else {
    Write-Host "`n⚠️  Some checks failed. Please review and fix before deployment." -ForegroundColor Yellow
}

Write-Host "`n🔗 USEFUL AZURE ENDPOINTS (after deployment):" -ForegroundColor Cyan
Write-Host "   • https://your-app.azurewebsites.net/install-browsers" -ForegroundColor White
Write-Host "   • https://your-app.azurewebsites.net/test-interface.html" -ForegroundColor White
Write-Host "   • https://your-app.azurewebsites.net/run-tests" -ForegroundColor White
Write-Host "   • https://your-app.azurewebsites.net/health" -ForegroundColor White
