# Azure App Service Deployment Guide

## Playwright Cucumber Framework for Azure

This guide explains how to deploy and run your Playwright Cucumber framework on Azure App Service.

## Files Created

1. **`run-tests.sh`** - Main executable bash script with comprehensive options
2. **`run-tests.ps1`** - PowerShell version for Windows environments
3. **`azure-startup.sh`** - Simplified startup script optimized for Azure App Service
4. **`Dockerfile`** - Container configuration for Docker deployment
5. **`azure-config.json`** - Azure App Service configuration

## Usage Options

### Local Development

```bash
# Make script executable (Linux/Mac)
chmod +x run-tests.sh

# Run all tests
./run-tests.sh

# Run with specific browser
./run-tests.sh --browser firefox

# Run in headed mode (visible browser)
./run-tests.sh --headed

# Run specific feature
./run-tests.sh --feature src/features/example.feature

# Run with tags
./run-tests.sh --tags "@smoke"

# Install dependencies only
./run-tests.sh --install-only
```

### Windows PowerShell

```powershell
# Run all tests
.\run-tests.ps1

# Run with specific options
.\run-tests.ps1 -Browser firefox -Headed

# Run specific feature
.\run-tests.ps1 -Feature "src/features/example.feature"

# Install only
.\run-tests.ps1 -InstallOnly
```

## Azure App Service Deployment

### Option 1: Direct Deployment

1. **Upload your code** to Azure App Service
2. **Set startup command** in Azure portal:
   ```bash
   ./azure-startup.sh
   ```
3. **Configure environment variables** in Azure portal:
   - `HEADLESS=true`
   - `CI=true`
   - `NODE_ENV=production`

### Option 2: Container Deployment

1. **Build Docker image**:
   ```bash
   docker build -t playwright-cucumber .
   ```

2. **Push to Azure Container Registry**:
   ```bash
   docker tag playwright-cucumber your-registry.azurecr.io/playwright-cucumber
   docker push your-registry.azurecr.io/playwright-cucumber
   ```

3. **Deploy to Azure App Service** using the container

### Option 3: GitHub Actions Deployment

Create `.github/workflows/deploy.yml`:

```yaml
name: Deploy to Azure App Service

on:
  push:
    branches: [ main ]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v2
    
    - name: Setup Node.js
      uses: actions/setup-node@v2
      with:
        node-version: '18'
    
    - name: Install dependencies
      run: npm ci
    
    - name: Run tests
      run: ./run-tests.sh --install-only
    
    - name: Deploy to Azure App Service
      uses: azure/webapps-deploy@v2
      with:
        app-name: 'your-app-name'
        slot-name: 'production'
        publish-profile: ${{ secrets.AZURE_WEBAPP_PUBLISH_PROFILE }}
        startup-command: './azure-startup.sh'
```

## Environment Variables

Configure these in Azure App Service:

| Variable | Value | Description |
|----------|-------|-------------|
| `HEADLESS` | `true` | Run browsers in headless mode |
| `CI` | `true` | Enable CI mode |
| `NODE_ENV` | `production` | Node environment |
| `BROWSER` | `chromium` | Default browser |
| `TEST_TIMEOUT` | `30000` | Test timeout in milliseconds |

## Monitoring and Logs

### View Logs
- Use Azure App Service logs
- Check `test-results/summary.txt` for test summaries
- HTML reports available at `test-results/cucumber-report.html`

### Health Checks
The container includes health checks to ensure Node.js is running properly.

## Troubleshooting

### Common Issues

1. **Permission denied on scripts**:
   ```bash
   chmod +x run-tests.sh azure-startup.sh
   ```

2. **Playwright browsers not found**:
   - Ensure `npx playwright install` runs successfully
   - Check `PLAYWRIGHT_BROWSERS_PATH` environment variable

3. **Tests timing out**:
   - Increase `TEST_TIMEOUT` environment variable
   - Ensure headless mode is enabled in Azure

4. **Memory issues**:
   - Use Azure App Service plans with sufficient memory
   - Consider reducing parallel test execution

### Debug Mode

Enable debug logging by adding these environment variables:
- `DEBUG=pw:*`
- `PLAYWRIGHT_DEBUG=1`

## Best Practices

1. **Always run in headless mode** in Azure
2. **Use specific browser versions** for consistency
3. **Implement proper error handling** in your tests
4. **Monitor resource usage** and scale appropriately
5. **Use test retries** for flaky tests
6. **Implement proper cleanup** after test runs

## Cost Optimization

- Use **Azure App Service Free/Shared tiers** for development
- Consider **Azure Container Instances** for occasional test runs
- Implement **scheduled runs** instead of continuous monitoring
- Use **spot instances** for cost-effective testing
