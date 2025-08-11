# 🔷 Azure App Service Configuration Guide
**For Playwright Cucumber TypeScript Framework**

## 📋 **STEP-BY-STEP AZURE CONFIGURATION**

### **1. General Settings**

Navigate to: **Azure Portal → Your App Service → Settings → Configuration → General settings**

#### **Stack Settings:**
```
Runtime stack: Node
Major version: 18 LTS (Recommended) or 20 LTS
Minor version: Latest available
```

#### **Platform Settings:**
```
Platform: 64 Bit
Web sockets: On
Always On: On (Prevents container sleep)
ARR affinity: Off (Better for load balancing)
```

#### **Debugging:**
```
Remote debugging: Off
```

---

## ⚙️ **2. Application Settings (Environment Variables)**

Navigate to: **Configuration → Application settings**

### **Required Environment Variables:**

| Name | Value | Purpose |
|------|-------|---------|
| `NODE_ENV` | `production` | Node.js environment mode |
| `HEADLESS` | `true` | Run browsers in headless mode |
| `CI` | `true` | Continuous integration mode |
| `LOG_LEVEL` | `info` | Logging verbosity (info/debug) |
| `PLAYWRIGHT_BROWSERS_PATH` | `/tmp/playwright-browsers` | Browser installation path |
| `BROWSER` | `chromium` | Default browser for tests |
| `TEST_TIMEOUT` | `30000` | Test timeout in milliseconds |
| `WEBSITE_NODE_DEFAULT_VERSION` | `18-lts` | Node.js version |

### **Optional Performance Settings:**

| Name | Value | Purpose |
|------|-------|---------|
| `WEBSITE_DYNAMIC_CACHE` | `0` | Disable dynamic cache |
| `WEBSITE_LOCAL_CACHE_OPTION` | `Always` | Enable local cache |
| `WEBSITE_LOCAL_CACHE_SIZEINMB` | `300` | Cache size limit |

### **🔧 How to Add Environment Variables:**

1. In Azure Portal → App Service → Configuration
2. Click **"+ New application setting"**
3. Enter **Name** and **Value**
4. Click **"OK"**
5. **Save** all settings
6. **Restart** the app service

---

## 📊 **3. Logging Configuration**

Navigate to: **Monitoring → Diagnostic settings**

### **Application Logging:**
```
Application Logging (Filesystem): On
Level: Information
Retention Period (Days): 7
```

### **Web Server Logging:**
```
Web server logging: On
Storage: File System
Retention Period (Days): 7
Quota (MB): 35
```

### **Detailed Error Messages:**
```
Detailed error messages: On
```

### **Failed Request Tracing:**
```
Failed request tracing: On
```

---

## 🚀 **4. Deployment Configuration**

Navigate to: **Deployment → Deployment Center**

### **GitHub Deployment (Recommended):**
```
Source: GitHub
Organization: [Your GitHub username]
Repository: pw_typescript_cucumber
Branch: main
Build provider: GitHub Actions
```

### **Manual Deployment Commands:**
If deploying manually via Azure CLI:

```bash
# Login to Azure
az login

# Deploy from local Git
az webapp deployment source config-local-git \
  --name YOUR_APP_NAME \
  --resource-group YOUR_RESOURCE_GROUP

# Push to Azure
git remote add azure [Azure Git URL from above command]
git push azure main
```

---

## 🔒 **5. Security & Authentication**

Navigate to: **Settings → Authentication**

### **For Public Access (Testing):**
```
Authentication: Off (Allow anonymous access)
```

### **For Secure Access:**
```
Authentication: On
Identity provider: Microsoft/Azure AD
Action to take when request is not authenticated: 
  Return HTTP 401 Unauthorized
```

---

## ⚡ **6. Performance & Scaling**

Navigate to: **Settings → Scale up (App Service plan)**

### **Recommended Plan for Testing:**
```
Plan: B1 Basic (1 Core, 1.75 GB RAM)
Cost: ~$13/month
Suitable for: Development and light testing
```

### **Production Plan:**
```
Plan: S2 Standard (2 Cores, 3.5 GB RAM)
Cost: ~$73/month
Features: Auto-scaling, Custom domains, SSL
```

### **Auto-scaling (For Standard+ plans):**
Navigate to: **Settings → Scale out (App Service plan)**
```
Enable autoscaling: On
Scale based on: CPU percentage
Scale out when CPU > 70%
Scale in when CPU < 30%
Instance range: 1-3 instances
```

---

## 🔧 **7. Advanced Configuration**

Navigate to: **Development Tools → Advanced Tools (Kudu)**

### **Startup Script Configuration:**
The framework uses `package.json` start script automatically:
```json
"start": "node server.js"
```

### **Custom Startup Command (if needed):**
Navigate to: **Configuration → General settings → Startup Command**
```bash
# Leave empty to use package.json start script
# Or specify custom command:
node server.js
```

---

## 📱 **8. Health Check Configuration**

Navigate to: **Monitoring → Health check**

```
Enable health check: On
Health check path: /health
```

This uses the health endpoint in your Express server:
```
https://your-app-name.azurewebsites.net/health
```

---

## 🌐 **9. Custom Domain & SSL (Optional)**

Navigate to: **Settings → Custom domains**

### **Add Custom Domain:**
1. Click **"+ Add custom domain"**
2. Enter your domain (e.g., `playwright.yourdomain.com`)
3. Add DNS records as instructed
4. Validate and add

### **SSL Certificate:**
```
SSL type: SNI SSL
Certificate source: App Service Managed Certificate (Free)
```

---

## 🔍 **10. Monitoring & Troubleshooting**

### **Application Insights (Recommended):**
Navigate to: **Settings → Application Insights**
```
Application Insights: On
Create new resource: [Your App Name]-ai
Location: Same as App Service
```

### **Log Stream:**
Navigate to: **Monitoring → Log stream**
- Real-time log viewing
- Useful for deployment troubleshooting

### **Metrics:**
Navigate to: **Monitoring → Metrics**
- Monitor CPU, Memory, HTTP requests
- Set up alerts for performance issues

---

## 🚨 **11. Common Configuration Issues & Fixes**

### **Issue: "Application Error"**
✅ **Fixed with our Express server.js**

### **Issue: "Container didn't respond to HTTP pings"**
**Solution:**
- Ensure `PORT` environment variable is used
- Health check endpoint is working
- Always On is enabled

### **Issue: "Module not found" errors**
**Solution:**
```
# Add to Application Settings:
WEBSITE_NODE_DEFAULT_VERSION = 18-lts
WEBSITE_NPM_DEFAULT_VERSION = 8
```

### **Issue: Playwright browser installation fails**
**Solution:**
```
# Add to Application Settings:
PLAYWRIGHT_BROWSERS_PATH = /tmp/playwright-browsers
PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD = false
```

---

## ✅ **12. Final Verification Checklist**

After configuration, verify these work:

- [ ] **App Service URL loads** → Shows Playwright framework homepage
- [ ] **Health check** → `https://your-app.azurewebsites.net/health` returns JSON
- [ ] **Test execution** → POST to `/run-tests` works
- [ ] **Log viewing** → `/test-results` shows logs
- [ ] **Application Insights** → Telemetry is being collected
- [ ] **Log Stream** → Real-time logs visible in Azure Portal

---

## 🎯 **13. Quick Setup Commands**

### **Azure CLI Quick Configuration:**
```bash
# Set basic app settings
az webapp config appsettings set \
  --resource-group YOUR_RESOURCE_GROUP \
  --name YOUR_APP_NAME \
  --settings NODE_ENV=production HEADLESS=true CI=true LOG_LEVEL=info

# Enable logging
az webapp log config \
  --resource-group YOUR_RESOURCE_GROUP \
  --name YOUR_APP_NAME \
  --application-logging filesystem \
  --level information

# Enable health check
az webapp config set \
  --resource-group YOUR_RESOURCE_GROUP \
  --name YOUR_APP_NAME \
  --health-check-path "/health"
```

### **PowerShell Configuration:**
```powershell
# Connect to Azure
Connect-AzAccount

# Set application settings
$settings = @{
    'NODE_ENV' = 'production'
    'HEADLESS' = 'true'
    'CI' = 'true'
    'LOG_LEVEL' = 'info'
    'PLAYWRIGHT_BROWSERS_PATH' = '/tmp/playwright-browsers'
}

Set-AzWebAppSettings -ResourceGroupName "YOUR_RESOURCE_GROUP" -Name "YOUR_APP_NAME" -AppSettings $settings
```

---

## 📞 **Need Help?**

If you encounter issues:
1. Check **Log stream** in Azure Portal
2. Verify **Application settings** are correct
3. Test **Health check endpoint**
4. Review **Application Insights** for errors

**🎯 With these settings, your Playwright Cucumber framework will run optimally in Azure App Service!**
