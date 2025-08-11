# 🔷 Azure App Service - Quick Setup Card

## 🚀 **ESSENTIAL SETTINGS ONLY**

### **1. Application Settings (Environment Variables)**
```
NODE_ENV = production
HEADLESS = true
CI = true
LOG_LEVEL = info
PLAYWRIGHT_BROWSERS_PATH = /tmp/playwright-browsers
BROWSER = chromium
TEST_TIMEOUT = 30000
```

### **2. General Settings**
```
Runtime stack: Node
Major version: 18 LTS
Platform: 64 Bit
Always On: On
```

### **3. Logging**
```
Application Logging (Filesystem): On
Level: Information
Retention: 7 days
```

### **4. Health Check**
```
Enable health check: On
Health check path: /health
```

### **5. Deployment**
```
Source: GitHub
Repository: pw_typescript_cucumber
Branch: main
Build provider: GitHub Actions
```

---

## ⚡ **QUICK AZURE CLI SETUP**

```bash
# Replace YOUR_APP_NAME and YOUR_RESOURCE_GROUP
APP_NAME="YOUR_APP_NAME"
RESOURCE_GROUP="YOUR_RESOURCE_GROUP"

# Set environment variables
az webapp config appsettings set \
  --resource-group $RESOURCE_GROUP \
  --name $APP_NAME \
  --settings \
    NODE_ENV=production \
    HEADLESS=true \
    CI=true \
    LOG_LEVEL=info \
    PLAYWRIGHT_BROWSERS_PATH=/tmp/playwright-browsers \
    BROWSER=chromium \
    TEST_TIMEOUT=30000

# Enable logging
az webapp log config \
  --resource-group $RESOURCE_GROUP \
  --name $APP_NAME \
  --application-logging filesystem \
  --level information

# Enable health check
az webapp config set \
  --resource-group $RESOURCE_GROUP \
  --name $APP_NAME \
  --health-check-path "/health"

echo "✅ Azure App Service configured!"
```

---

## 🎯 **VERIFICATION URLS**

After setup, test these:
- **Homepage:** `https://YOUR_APP_NAME.azurewebsites.net`
- **Health Check:** `https://YOUR_APP_NAME.azurewebsites.net/health`
- **Test Results:** `https://YOUR_APP_NAME.azurewebsites.net/test-results`

---

## 🚨 **TROUBLESHOOTING**

**Application Error?**
1. Check: Log Stream in Azure Portal
2. Verify: All environment variables set
3. Test: Health check endpoint

**Deployment Issues?**
1. Check: GitHub Actions logs
2. Verify: Repository permissions
3. Restart: App Service

**Performance Issues?**
1. Enable: Always On
2. Upgrade: To Standard plan
3. Monitor: Application Insights
