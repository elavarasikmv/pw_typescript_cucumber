# 🚀 Azure App Service Deployment Configuration Guide

## 📋 **Step 1: Azure Portal Configuration**

### A. Create App Service (if not already created)
1. Go to Azure Portal → Create Resource → Web App
2. Choose your subscription and resource group
3. Set Web App name (e.g., `playwright-cucumber-app`)
4. Runtime stack: **Node 18 LTS** or higher
5. Operating System: **Linux**
6. Region: Choose nearest to your location
7. Create new App Service Plan or use existing

### B. Configure Application Settings
1. Go to **App Service → Configuration → Application settings**
2. Add the following settings (copy from `azure-app-settings.txt`):

```
PLAYWRIGHT_BROWSERS_PATH = /home/site/wwwroot/browsers
PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD = false
PLAYWRIGHT_SKIP_VALIDATE_HOST_REQUIREMENTS = true
PLAYWRIGHT_CACHE_DIR = /home/site/wwwroot/.cache
PLAYWRIGHT_DOWNLOAD_HOST = https://playwright.azureedge.net
NODE_ENV = production
NODE_OPTIONS = --max-old-space-size=2048
WEBSITE_NODE_DEFAULT_VERSION = 18.17.0
PORT = 8080
HEADLESS = true
CI = true
AZURE_DEPLOYMENT = true
BROWSER = chromium
CHROME_DEVEL_SANDBOX = false
PUPPETEER_SKIP_CHROMIUM_DOWNLOAD = true
SCM_DO_BUILD_DURING_DEPLOYMENT = true
ENABLE_ORYX_BUILD = true
BUILD_FLAGS = useExpressServer
WEBSITE_ENABLE_SYNC_UPDATE_SITE = true
TEST_TIMEOUT = 30000
WEBSITE_DYNAMIC_CACHE = 0
WEBSITE_LOCAL_CACHE_OPTION = Never
WEBSITE_LOCAL_CACHE_SIZEINMB = 0
LOG_LEVEL = info
LOGGING_ENABLED = true
WEBSITE_HTTPLOGGING_RETENTION_DAYS = 7
```

### C. Configure General Settings
1. Go to **Configuration → General settings**
2. Set **Startup Command**: `node server.js`
3. Set **Platform**: 64 Bit
4. Set **Node.js version**: 18.17.0 or higher
5. Enable **HTTP logs** and **Detailed error messages**
6. **Save** the configuration

## 📋 **Step 2: Deployment Options**

### Option A: GitHub Actions (Recommended)
1. Go to **App Service → Deployment Center**
2. Choose **GitHub** as source
3. Select your repository and branch
4. Azure will auto-generate a workflow file
5. The deployment will trigger automatically on push

### Option B: Azure DevOps
1. Go to **App Service → Deployment Center**
2. Choose **Azure DevOps** as source
3. Configure your Azure DevOps project and repository
4. Set up build and release pipelines

### Option C: Git Deployment
1. Go to **App Service → Deployment Center**
2. Choose **Local Git** as source
3. Get the Git clone URL
4. Add as remote: `git remote add azure <clone-url>`
5. Deploy: `git push azure main`

### Option D: ZIP Deployment
1. Create a ZIP file of your project (exclude node_modules)
2. Use Azure CLI: `az webapp deployment source config-zip --resource-group <rg> --name <app-name> --src <zip-file>`

## 📋 **Step 3: Post-Deployment Configuration**

### A. Install Browsers (CRITICAL STEP)
1. Go to your app URL: `https://your-app.azurewebsites.net`
2. Navigate to: `https://your-app.azurewebsites.net/install-browsers`
3. Wait for browser installation to complete (5-10 minutes)
4. Verify installation at: `https://your-app.azurewebsites.net/check-browser`

### B. Test the Application
1. **Test Interface**: `https://your-app.azurewebsites.net/test-interface.html`
2. **Health Check**: `https://your-app.azurewebsites.net/health`
3. **Run Tests**: `https://your-app.azurewebsites.net/run-tests`

## 📋 **Step 4: Monitoring and Troubleshooting**

### A. Enable Logging
1. Go to **App Service → Monitoring → Log Stream**
2. Enable **Application Logging** and **Web Server Logging**
3. Monitor real-time logs during testing

### B. Common Issues and Solutions

#### Issue: "Route not found" errors
- **Solution**: Ensure `web.config` is properly deployed
- **Check**: Application settings are correctly configured

#### Issue: Browser installation fails
- **Solution**: Increase App Service Plan size (minimum B1)
- **Check**: PLAYWRIGHT_BROWSERS_PATH is set correctly

#### Issue: Tests timeout
- **Solution**: Increase TEST_TIMEOUT value
- **Check**: App Service Plan has sufficient resources

#### Issue: Memory errors
- **Solution**: Increase NODE_OPTIONS max memory
- **Check**: Consider upgrading App Service Plan

### C. Performance Optimization
1. Use **Premium** App Service Plan for production
2. Enable **Always On** in Configuration
3. Configure **Auto Scaling** based on CPU/Memory
4. Use **Application Insights** for monitoring

## 📋 **Step 5: Security Configuration**

### A. Network Security
1. Configure **IP Restrictions** if needed
2. Enable **HTTPS Only**
3. Configure **TLS/SSL settings**

### B. Identity and Access
1. Configure **Authentication** if required
2. Set up **Managed Identity** for Azure resources
3. Configure **CORS** settings if needed

## 📋 **Step 6: Backup and Disaster Recovery**

1. Enable **Backup** in App Service
2. Configure **Geo-replication** if needed
3. Set up **Monitoring Alerts**
4. Document **Recovery Procedures**

## 🎯 **Quick Deployment Checklist**

- [ ] App Service created with Node.js 18+ runtime
- [ ] All application settings configured from `azure-app-settings.txt`
- [ ] Startup command set to `node server.js`
- [ ] Code deployed via preferred method
- [ ] Browser installation completed via `/install-browsers`
- [ ] Application tested via `/test-interface.html`
- [ ] Logging enabled and monitored
- [ ] Performance baseline established

## 📞 **Support Resources**

- **Azure App Service Documentation**: https://docs.microsoft.com/azure/app-service/
- **Node.js on Azure**: https://docs.microsoft.com/azure/app-service/quickstart-nodejs
- **Playwright Documentation**: https://playwright.dev/docs/ci
- **Application Logs**: App Service → Monitoring → Log Stream

## 🚨 **Emergency Procedures**

If deployment fails:
1. Check **Activity Log** in Azure Portal
2. Review **Deployment Logs** in Deployment Center
3. Use **SSH Console** to debug: App Service → Development Tools → SSH
4. Restart App Service: Overview → Restart
5. Check **Resource Health**: Overview → Resource Health

Your Playwright Cucumber application is now ready for production deployment on Azure! 🎉
