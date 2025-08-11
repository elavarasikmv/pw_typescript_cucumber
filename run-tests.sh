#!/bin/bash

# Playwright Cucumber Test Runner Script
# This script sets up and runs the Playwright Cucumber framework
# Suitable for Azure App Service deployment

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Default values
BROWSER="chromium"
HEADLESS="true"
ENVIRONMENT="production"
REPORT_FORMAT="html,json"
TIMEOUT="30000"
WORKERS="1"

# Function to show usage
show_usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -b, --browser BROWSER     Browser to use (chromium, firefox, webkit) [default: chromium]"
    echo "  -h, --headless            Run in headless mode [default: true]"
    echo "  --headed                  Run in headed mode (visible browser)"
    echo "  -e, --env ENVIRONMENT     Environment (dev, staging, production) [default: production]"
    echo "  -t, --timeout TIMEOUT     Test timeout in milliseconds [default: 30000]"
    echo "  -w, --workers WORKERS     Number of parallel workers [default: 1]"
    echo "  -f, --format FORMAT       Report format (html, json, summary) [default: html,json]"
    echo "  --feature FEATURE         Run specific feature file"
    echo "  --tags TAGS               Run tests with specific tags"
    echo "  --install-only            Only install dependencies, don't run tests"
    echo "  --setup-only              Only setup environment, don't run tests"
    echo "  --help                    Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0                                    # Run all tests with default settings"
    echo "  $0 --browser firefox --headed        # Run in Firefox with visible browser"
    echo "  $0 --feature example.feature         # Run specific feature"
    echo "  $0 --tags @smoke                     # Run tests tagged with @smoke"
    echo "  $0 --install-only                    # Only install dependencies"
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -b|--browser)
            BROWSER="$2"
            shift 2
            ;;
        -h|--headless)
            HEADLESS="true"
            shift
            ;;
        --headed)
            HEADLESS="false"
            shift
            ;;
        -e|--env)
            ENVIRONMENT="$2"
            shift 2
            ;;
        -t|--timeout)
            TIMEOUT="$2"
            shift 2
            ;;
        -w|--workers)
            WORKERS="$2"
            shift 2
            ;;
        -f|--format)
            REPORT_FORMAT="$2"
            shift 2
            ;;
        --feature)
            FEATURE_FILE="$2"
            shift 2
            ;;
        --tags)
            TAGS="$2"
            shift 2
            ;;
        --install-only)
            INSTALL_ONLY="true"
            shift
            ;;
        --setup-only)
            SETUP_ONLY="true"
            shift
            ;;
        --help)
            show_usage
            exit 0
            ;;
        *)
            print_error "Unknown option: $1"
            show_usage
            exit 1
            ;;
    esac
done

# Validate browser option
if [[ ! "$BROWSER" =~ ^(chromium|firefox|webkit)$ ]]; then
    print_error "Invalid browser: $BROWSER. Must be chromium, firefox, or webkit"
    exit 1
fi

print_status "Starting Playwright Cucumber Test Runner..."
print_status "Browser: $BROWSER"
print_status "Headless: $HEADLESS"
print_status "Environment: $ENVIRONMENT"

# Check if Node.js is installed
if ! command -v node &> /dev/null; then
    print_error "Node.js is not installed. Please install Node.js 16 or higher."
    exit 1
fi

# Check Node.js version
NODE_VERSION=$(node --version | cut -d'v' -f2)
REQUIRED_VERSION="16.0.0"

if ! node -e "process.exit(process.version.slice(1).split('.').map(Number).reduce((a,b,i)=>[16,0,0][i]>b?1:0).includes(1)?1:0)"; then
    print_warning "Node.js version $NODE_VERSION detected. Version 16+ recommended."
fi

# Function to setup environment
setup_environment() {
    print_status "Setting up environment..."
    
    # Create necessary directories
    mkdir -p test-results/screenshots
    mkdir -p test-results/videos
    mkdir -p test-results/traces
    
    # Set environment variables
    export HEADLESS="$HEADLESS"
    export BROWSER="$BROWSER"
    export TEST_TIMEOUT="$TIMEOUT"
    export ENVIRONMENT="$ENVIRONMENT"
    
    # Azure-specific environment variables
    if [ ! -z "$WEBSITE_HOSTNAME" ]; then
        print_status "Running in Azure App Service environment"
        export AZURE_DEPLOYMENT="true"
        export CI="true"
        # Ensure headless mode in Azure
        export HEADLESS="true"
    fi
    
    print_success "Environment setup completed"
}

# Function to install dependencies
install_dependencies() {
    print_status "Installing dependencies..."
    
    # Check if package.json exists
    if [ ! -f "package.json" ]; then
        print_error "package.json not found. Make sure you're in the correct directory."
        exit 1
    fi
    
    # Install npm dependencies
    if ! npm ci --silent; then
        print_warning "npm ci failed, trying npm install..."
        npm install
    fi
    
    # Install Playwright browsers
    print_status "Installing Playwright browsers..."
    npx playwright install --with-deps
    
    print_success "Dependencies installed successfully"
}

# Function to run tests
run_tests() {
    print_status "Running Playwright Cucumber tests..."
    
    # Build cucumber command
    CUCUMBER_CMD="cucumber-js --config=config/cucumber.js"
    
    # Add browser profile
    if [ "$BROWSER" != "chromium" ]; then
        CUCUMBER_CMD="$CUCUMBER_CMD --profile=$BROWSER"
    fi
    
    # Add specific feature file if provided
    if [ ! -z "$FEATURE_FILE" ]; then
        CUCUMBER_CMD="$CUCUMBER_CMD $FEATURE_FILE"
    fi
    
    # Add tags if provided
    if [ ! -z "$TAGS" ]; then
        CUCUMBER_CMD="$CUCUMBER_CMD --tags '$TAGS'"
    fi
    
    # Add format options
    CUCUMBER_CMD="$CUCUMBER_CMD --format summary --format progress-bar"
    
    if [[ "$REPORT_FORMAT" == *"html"* ]]; then
        CUCUMBER_CMD="$CUCUMBER_CMD --format html:test-results/cucumber-report.html"
    fi
    
    if [[ "$REPORT_FORMAT" == *"json"* ]]; then
        CUCUMBER_CMD="$CUCUMBER_CMD --format json:test-results/cucumber-report.json"
    fi
    
    # Add parallel workers if specified
    if [ "$WORKERS" -gt 1 ]; then
        CUCUMBER_CMD="$CUCUMBER_CMD --parallel $WORKERS"
    fi
    
    print_status "Executing: $CUCUMBER_CMD"
    
    # Run the tests
    if eval $CUCUMBER_CMD; then
        print_success "All tests passed successfully!"
        TEST_RESULT=0
    else
        print_error "Some tests failed. Check the reports for details."
        TEST_RESULT=1
    fi
    
    # Generate summary
    generate_summary
    
    return $TEST_RESULT
}

# Function to generate test summary
generate_summary() {
    print_status "Generating test summary..."
    
    # Create a simple summary file
    cat > test-results/summary.txt << EOF
Test Execution Summary
=====================
Date: $(date)
Browser: $BROWSER
Headless: $HEADLESS
Environment: $ENVIRONMENT
Node Version: $(node --version)

Reports generated:
- HTML Report: test-results/cucumber-report.html
- JSON Report: test-results/cucumber-report.json
- Screenshots: test-results/screenshots/
- Videos: test-results/videos/
EOF
    
    # Display file sizes if reports exist
    if [ -f "test-results/cucumber-report.html" ]; then
        echo "- HTML Report Size: $(du -h test-results/cucumber-report.html | cut -f1)" >> test-results/summary.txt
    fi
    
    if [ -f "test-results/cucumber-report.json" ]; then
        echo "- JSON Report Size: $(du -h test-results/cucumber-report.json | cut -f1)" >> test-results/summary.txt
    fi
    
    print_success "Summary generated at test-results/summary.txt"
}

# Function to cleanup
cleanup() {
    print_status "Cleaning up..."
    
    # Kill any remaining browser processes
    pkill -f "chrome|firefox|webkit" 2>/dev/null || true
    
    # Compress old reports if they exist
    if [ -d "test-results" ]; then
        find test-results -name "*.html" -o -name "*.json" -mtime +7 -exec gzip {} \; 2>/dev/null || true
    fi
}

# Main execution
main() {
    # Setup signal handlers for cleanup
    trap cleanup EXIT
    trap 'print_error "Script interrupted"; exit 130' INT
    trap 'print_error "Script terminated"; exit 143' TERM
    
    # Change to script directory
    cd "$(dirname "$0")"
    
    # Setup environment
    setup_environment
    
    # Install dependencies
    install_dependencies
    
    # Exit early if install-only flag is set
    if [ "$INSTALL_ONLY" = "true" ]; then
        print_success "Dependencies installed. Exiting as requested."
        exit 0
    fi
    
    # Exit early if setup-only flag is set
    if [ "$SETUP_ONLY" = "true" ]; then
        print_success "Environment setup completed. Exiting as requested."
        exit 0
    fi
    
    # Run tests
    run_tests
    TEST_EXIT_CODE=$?
    
    # Cleanup
    cleanup
    
    if [ $TEST_EXIT_CODE -eq 0 ]; then
        print_success "Test execution completed successfully!"
    else
        print_error "Test execution completed with failures."
    fi
    
    exit $TEST_EXIT_CODE
}

# Run main function
main "$@"
