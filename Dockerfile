# Dockerfile for Playwright Cucumber Framework
# Optimized for Azure App Service

FROM mcr.microsoft.com/playwright:v1.40.0-jammy

# Set working directory
WORKDIR /app

# Set environment variables
ENV NODE_ENV=production
ENV HEADLESS=true
ENV CI=true
ENV PLAYWRIGHT_BROWSERS_PATH=/ms-playwright

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm ci --only=production

# Copy application code
COPY . .

# Install Playwright browsers
RUN npx playwright install --with-deps chromium

# Create directories for test results
RUN mkdir -p test-results/screenshots test-results/videos

# Make scripts executable
RUN chmod +x run-tests.sh azure-startup.sh

# Expose port for web interface (optional)
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 \
    CMD node --version || exit 1

# Default command
CMD ["./azure-startup.sh"]
