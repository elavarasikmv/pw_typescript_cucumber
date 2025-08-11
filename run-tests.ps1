# Playwright Cucumber Test Runner for Azure App Service
# PowerShell version for Windows environments

param(
    [string]$Browser = "chromium",
    [switch]$Headed = $false,
    [string]$Environment = "production",
    [string]$Feature = "",
    [string]$Tags = "",
    [switch]$InstallOnly = $false,
    [switch]$SetupOnly = $false,
    [switch]$Help = $false
)

# Colors for output
function Write-Status {
    param([string]$Message)
    Write-Host "[INFO] $Message" -ForegroundColor Blue
}

function Write-Success {
    param([string]$Message)
    Write-Host "[SUCCESS] $Message" -ForegroundColor Green
}

function Write-Warning {
    param([string]$Message)
    Write-Host "[WARNING] $Message" -ForegroundColor Yellow
}

function Write-Error {
    param([string]$Message)
    Write-Host "[ERROR] $Message" -ForegroundColor Red
}

function Show-Usage {
    Write-Host "Usage: .\run-tests.ps1 [OPTIONS]"
    Write-Host ""
    Write-Host "Options:"
    Write-Host "  -Browser BROWSER      Browser to use (chromium, firefox, webkit) [default: chromium]"
    Write-Host "  -Headed              Run in headed mode (visible browser)"
    Write-Host "  -Environment ENV     Environment (dev, staging, production) [default: production]"
    Write-Host "  -Feature FEATURE     Run specific feature file"
    Write-Host "  -Tags TAGS           Run tests with specific tags"
    Write-Host "  -InstallOnly         Only install dependencies, don't run tests"
    Write-Host "  -SetupOnly           Only setup environment, don't run tests"
    Write-Host "  -Help                Show this help message"
    Write-Host ""
    Write-Host "Examples:"
    Write-Host "  .\run-tests.ps1                                    # Run all tests with default settings"
    Write-Host "  .\run-tests.ps1 -Browser firefox -Headed          # Run in Firefox with visible browser"
    Write-Host "  .\run-tests.ps1 -Feature example.feature          # Run specific feature"
    Write-Host "  .\run-tests.ps1 -Tags '@smoke'                    # Run tests tagged with @smoke"
    Write-Host "  .\run-tests.ps1 -InstallOnly                      # Only install dependencies"
}

if ($Help) {
    Show-Usage
    exit 0
}

# Validate browser option
if ($Browser -notin @("chromium", "firefox", "webkit")) {
    Write-Error "Invalid browser: $Browser. Must be chromium, firefox, or webkit"
    exit 1
}

Write-Status "Starting Playwright Cucumber Test Runner..."
Write-Status "Browser: $Browser"
Write-Status "Headless: $(-not $Headed)"
Write-Status "Environment: $Environment"

# Check if Node.js is installed
try {
    $nodeVersion = node --version
    Write-Status "Node.js version: $nodeVersion"
} catch {
    Write-Error "Node.js is not installed. Please install Node.js 16 or higher."
    exit 1
}

# Setup environment
function Setup-Environment {
    Write-Status "Setting up environment..."
    
    # Create necessary directories
    New-Item -ItemType Directory -Force -Path "test-results\screenshots" | Out-Null
    New-Item -ItemType Directory -Force -Path "test-results\videos" | Out-Null
    New-Item -ItemType Directory -Force -Path "test-results\traces" | Out-Null
    
    # Set environment variables
    $env:HEADLESS = if ($Headed) { "false" } else { "true" }
    $env:BROWSER = $Browser
    $env:ENVIRONMENT = $Environment
    
    # Azure-specific environment variables
    if ($env:WEBSITE_HOSTNAME) {
        Write-Status "Running in Azure App Service environment"
        $env:AZURE_DEPLOYMENT = "true"
        $env:CI = "true"
        # Ensure headless mode in Azure
        $env:HEADLESS = "true"
    }
    
    Write-Success "Environment setup completed"
}

# Install dependencies
function Install-Dependencies {
    Write-Status "Installing dependencies..."
    
    # Check if package.json exists
    if (-not (Test-Path "package.json")) {
        Write-Error "package.json not found. Make sure you're in the correct directory."
        exit 1
    }
    
    # Install npm dependencies
    try {
        npm ci --silent
    } catch {
        Write-Warning "npm ci failed, trying npm install..."
        npm install
    }
    
    # Install Playwright browsers
    Write-Status "Installing Playwright browsers..."
    npx playwright install --with-deps
    
    Write-Success "Dependencies installed successfully"
}

# Run tests
function Run-Tests {
    Write-Status "Running Playwright Cucumber tests..."
    
    # Build cucumber command
    $cucumberCmd = "cucumber-js --config=config/cucumber.js"
    
    # Add browser profile
    if ($Browser -ne "chromium") {
        $cucumberCmd += " --profile=$Browser"
    }
    
    # Add specific feature file if provided
    if ($Feature) {
        $cucumberCmd += " $Feature"
    }
    
    # Add tags if provided
    if ($Tags) {
        $cucumberCmd += " --tags '$Tags'"
    }
    
    # Add format options
    $cucumberCmd += " --format summary --format progress-bar"
    $cucumberCmd += " --format html:test-results/cucumber-report.html"
    $cucumberCmd += " --format json:test-results/cucumber-report.json"
    
    Write-Status "Executing: $cucumberCmd"
    
    # Run the tests
    $testResult = 0
    try {
        Invoke-Expression $cucumberCmd
        Write-Success "All tests passed successfully!"
    } catch {
        Write-Error "Some tests failed. Check the reports for details."
        $testResult = 1
    }
    
    # Generate summary
    Generate-Summary
    
    return $testResult
}

# Generate test summary
function Generate-Summary {
    Write-Status "Generating test summary..."
    
    $summaryContent = @"
Test Execution Summary
=====================
Date: $(Get-Date)
Browser: $Browser
Headless: $(-not $Headed)
Environment: $Environment
Node Version: $(node --version)

Reports generated:
- HTML Report: test-results/cucumber-report.html
- JSON Report: test-results/cucumber-report.json
- Screenshots: test-results/screenshots/
- Videos: test-results/videos/
"@
    
    $summaryContent | Out-File -FilePath "test-results\summary.txt" -Encoding UTF8
    
    Write-Success "Summary generated at test-results\summary.txt"
}

# Main execution
try {
    # Change to script directory
    Set-Location $PSScriptRoot
    
    # Setup environment
    Setup-Environment
    
    # Install dependencies
    Install-Dependencies
    
    # Exit early if install-only flag is set
    if ($InstallOnly) {
        Write-Success "Dependencies installed. Exiting as requested."
        exit 0
    }
    
    # Exit early if setup-only flag is set
    if ($SetupOnly) {
        Write-Success "Environment setup completed. Exiting as requested."
        exit 0
    }
    
    # Run tests
    $testExitCode = Run-Tests
    
    if ($testExitCode -eq 0) {
        Write-Success "Test execution completed successfully!"
    } else {
        Write-Error "Test execution completed with failures."
    }
    
    exit $testExitCode
} catch {
    Write-Error "An error occurred: $($_.Exception.Message)"
    exit 1
}
