# 🚨 Azure App Service Error - Fix Checklist

## ✅ **IMMEDIATE FIXES TO DEPLOY**

### **1. Fixed Files Created:**
- ✅ `server.js` - Express web server (fixes "Application Error")
- ✅ `package.json` - Updated start script to use `node server.js`
- ✅ `azure-diagnostics.sh` - Diagnostic commands
- ✅ Added Express dependency

### **2. Deploy These Changes:**

```bash
# Commit and push the fixes
git add .
git commit -m "fix: Add Express server to resolve Azure App Service error

- Add server.js with Express web server
- Update package.json start script  
- Add Express dependency
- Fix Azure App Service startup issues"

git push origin master
```

### **3. Azure Configuration Required:**

#### **A. In Azure Portal:**
1. Go to your App Service
2. **Configuration** → **General Settings**
3. **Startup Command:** Leave empty (will use package.json start script)
4. **Stack settings:**
   - **Stack:** Node
   - **Major version:** 18 LTS (or 20 LTS)
   - **Minor version:** Latest

#### **B. Application Settings:**
Add these environment variables in **Configuration** → **Application settings**:

```
NODE_ENV = production
HEADLESS = true
CI = true
PORT = 8080
LOG_LEVEL = info
```

#### **C. Enable Logging:**
1. **Monitoring** → **Diagnostic settings**
2. Turn ON **Application Logging (Filesystem)**
3. **Level:** Information
4. **Retention:** 7 days

---

## 🔍 **TROUBLESHOOTING STEPS**

### **Step 1: Check Deployment Status**
```bash
# If using Azure CLI
az webapp log tail --name YOUR_APP_NAME --resource-group YOUR_RESOURCE_GROUP

# Or check in Azure Portal:
# App Service → Deployment Center → Logs
```

### **Step 2: Test Locally First**
```bash
# Test the server locally
npm start

# Should output:
# 🚀 Playwright Cucumber Framework is running!
# 🌐 Server: http://localhost:8080
```

### **Step 3: Check Azure Logs**
In Azure Portal:
1. **App Service** → **Log stream**
2. Look for startup errors or missing dependencies

### **Step 4: Common Azure Issues & Fixes**

| Issue | Solution |
|-------|----------|
| "Application Error" | ✅ **FIXED**: Added Express server |
| Missing dependencies | Ensure `package.json` includes Express |
| Wrong startup command | ✅ **FIXED**: Changed to `node server.js` |
| Port issues | ✅ **FIXED**: Uses `process.env.PORT` |
| Logging not working | ✅ **READY**: Winston logger integrated |

---

## 🎯 **WHAT THE FIX DOES**

### **Before (Problem):**
- Package.json had: `"start": "node --version && npm test"`
- No web server running continuously
- Tests would run once and exit
- Azure expects a long-running web process

### **After (Fixed):**
- Package.json now has: `"start": "node server.js"`
- Express web server runs continuously ✅
- Web interface at your Azure URL ✅
- Can trigger tests via web endpoints ✅
- Proper logging and monitoring ✅

---

## 🌐 **YOUR AZURE URL WILL SHOW:**

Once deployed, your Azure App Service URL will display:
```
🎭 Playwright Cucumber Framework
✅ Service Status: Running successfully!

Available Endpoints:
• /health - Health check endpoint
• /test-results - View test results and logs  
• /run-tests - Run Playwright tests (POST request)
```

**🔗 URL Format:** `https://your-app-name.azurewebsites.net`

---

## 🚀 **DEPLOYMENT COMMAND**

Run this to deploy the fix:

```bash
git add .
git commit -m "fix: Resolve Azure App Service error with Express server"
git push origin master
```

**⏱️ Expected deployment time:** 2-5 minutes

**✅ Success indicator:** Your Azure URL loads the Playwright framework homepage instead of "Application Error"

---

## 📞 **NEED HELP?**

If you still get errors after deploying:

1. **Check Azure logs** in Portal → App Service → Log stream
2. **Run diagnostic command:** 
   ```bash
   az webapp log tail --name YOUR_APP_NAME --resource-group YOUR_RESOURCE_GROUP
   ```
3. **Verify environment variables** in Portal → Configuration → Application settings

**🎯 This fix should resolve your "Application Error" issue!**
