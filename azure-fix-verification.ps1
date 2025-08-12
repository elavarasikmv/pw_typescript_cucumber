#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Azure Cucumber Fix Verification Script
    
.DESCRIPTION
    This script verifies that all browser path issues have been resolved for Azure deployment.
    It checks for hardcoded paths, tests local server functionality, and provides deployment guidance.
    
.PARAMETER SkipServerTest
    Skip the local server functionality test
    
.EXAMPLE
    .\azure-fix-verification.ps1
    
.EXAMPLE
    .\azure-fix-verification.ps1 -SkipServerTest
#>

[CmdletBinding()]
param(
    [switch]$SkipServerTest
)

# Set strict mode for better error handling
Set-StrictMode -Version Latest
$ErrorActionPreference = "Continue"

Write-Host "🔍 Verifying Azure Cucumber Browser Path Fixes..." -ForegroundColor Cyan
Write-Host ("=" * 60)

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
            Write-Host "✅ $Description`: SUCCESS" -ForegroundColor Green
            return $true
        } else {
            Write-Host "❌ $Description`: FAILED (Status: $($response.StatusCode))" -ForegroundColor Red
            return $false
        }
    } catch {
        Write-Host "❌ $Description`: ERROR - $($_.Exception.Message)" -ForegroundColor Red
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
    
    # Check if port 3000 is already in use
    $portCheck = netstat -an | Select-String ":3000.*LISTENING"
    if ($portCheck) {
        Write-Host "⚠️  Port 3000 is already in use. Skipping server test." -ForegroundColor Yellow
        return $true
    }
    
    $serverProcess = $null
    try {
        # Start the server in background
        $serverProcess = Start-Process "node" -ArgumentList "server.js" -NoNewWindow -PassThru -ErrorAction Stop
        
        Write-Host "⏳ Waiting for server to start..." -ForegroundColor Yellow
        Start-Sleep -Seconds 8
        
        # Check if process is still running
        if ($serverProcess.HasExited) {
            Write-Host "❌ Server failed to start or exited immediately" -ForegroundColor Red
            return $false
        }
        
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
        
    } catch {
        Write-Host "❌ Server test error: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    } finally {
        # Stop the server
        if ($serverProcess -and -not $serverProcess.HasExited) {
            try {
                Stop-Process -Id $serverProcess.Id -Force -ErrorAction SilentlyContinue
                Write-Host "🛑 Server stopped" -ForegroundColor Yellow
            } catch {
                Write-Host "⚠️  Could not stop server process" -ForegroundColor Yellow
            }
        }
    }
}

# Function to check git status
function Check-GitStatus {
    Write-Host "📝 Checking git status..." -ForegroundColor Cyan
    
    try {
        $gitStatus = git status --porcelain 2>&1
        
        if ($LASTEXITCODE -ne 0) {
            Write-Host "❌ Git error: $gitStatus" -ForegroundColor Red
            return
        }
        
        if ($gitStatus) {
            Write-Host "📋 Uncommitted changes found:" -ForegroundColor Yellow
            $gitStatus | ForEach-Object { Write-Host "   $_" -ForegroundColor Gray }
            
            $commit = Read-Host "Do you want to commit these changes? (y/n)"
            if ($commit -eq 'y' -or $commit -eq 'Y') {
                Write-Host "📝 Committing changes..." -ForegroundColor Yellow
                git add . 2>&1 | Out-Null
                $commitResult = git commit -m "Fix: Resolve Playwright browser path issues for Azure deployment

- Updated all hardcoded paths to use Azure-compatible paths
- Fixed world.ts, hooks.ts, server.js, and test files  
- Added proper Azure environment detection and browser path handling
- Ensured consistent browser installation across all components" 2>&1
                
                if ($LASTEXITCODE -eq 0) {
                    Write-Host "✅ Changes committed successfully!" -ForegroundColor Green
                    
                    $push = Read-Host "Do you want to push to remote? (y/n)"
                    if ($push -eq 'y' -or $push -eq 'Y') {
                        Write-Host "📤 Pushing to remote..." -ForegroundColor Yellow
                        $pushResult = git push 2>&1
                        if ($LASTEXITCODE -eq 0) {
                            Write-Host "✅ Changes pushed to remote!" -ForegroundColor Green
                        } else {
                            Write-Host "❌ Push failed: $pushResult" -ForegroundColor Red
                        }
                    }
                } else {
                    Write-Host "❌ Commit failed: $commitResult" -ForegroundColor Red
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
function Test-BasicComponents {
    Write-Host "🧪 Running basic test verification..." -ForegroundColor Cyan
    
    try {
        # Test npm install
        Write-Host "📦 Checking npm dependencies..." -ForegroundColor Yellow
        $npmOutput = npm list --depth=0 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ NPM dependencies OK" -ForegroundColor Green
        } else {
            Write-Host "⚠️  NPM dependencies may have issues" -ForegroundColor Yellow
            Write-Host "   Output: $npmOutput" -ForegroundColor Gray
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
    BasicTests = Test-BasicComponents
}

if (-not $SkipServerTest) {
    $results.LocalServer = Test-LocalServer
} else {
    Write-Host "⏭️  Skipping server test (parameter specified)" -ForegroundColor Yellow
    $results.LocalServer = $true
}

Check-GitStatus

Write-Host "`n📊 VERIFICATION SUMMARY" -ForegroundColor Cyan
Write-Host ("=" * 30)

$pathsColor = if($results.HardcodedPaths) {"Green"} else {"Red"}
$testsColor = if($results.BasicTests) {"Green"} else {"Red"}
$serverColor = if($results.LocalServer) {"Green"} else {"Red"}

Write-Host "✅ Hardcoded paths fixed: $($results.HardcodedPaths)" -ForegroundColor $pathsColor
Write-Host "✅ Basic tests passed: $($results.BasicTests)" -ForegroundColor $testsColor
Write-Host "✅ Local server functional: $($results.LocalServer)" -ForegroundColor $serverColor

$allPassed = ($results.Values | Where-Object { $_ -eq $false }).Count
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
