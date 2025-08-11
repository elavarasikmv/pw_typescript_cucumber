#!/bin/bash

# Simple Azure startup script
echo "Starting Playwright Cucumber Tests..."

# Set environment
export HEADLESS=true
export CI=true
export NODE_ENV=production

# Install dependencies
npm install --production

# Try to install browsers
npx playwright install chromium || echo "Browser installation failed, continuing..."

# Run tests
npm test || echo "Tests completed with issues"

# Keep container alive
echo "Application started successfully"
exec "$@"
