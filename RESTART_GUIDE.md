# How to Restart Your Playwright Framework in Azure

## 🔄 App Service Restart (Most Common)

### Azure Portal Method:
1. Go to: https://portal.azure.com
2. Navigate to: App Services → playwright-cucumber-tests (your app name)
3. Click: **"Restart"** button in the top toolbar
4. Confirm: Click "Yes" 
5. Wait: 30-60 seconds for restart to complete

### Azure CLI Method:
```bash
# Replace with your actual names
az webapp restart --name playwright-cucumber-tests --resource-group your-resource-group
```

## 🚀 Pipeline Restart 

### Re-run Deployment Pipeline:
1. Go to: Azure DevOps → Pipelines
2. Select: Your pipeline
3. Click: **"Run pipeline"**
4. Choose: Branch (usually main)
5. Click: **"Run"**

### Cancel and Restart:
1. Go to: Running pipeline
2. Click: **"Cancel"** 
3. Wait: For cancellation
4. Click: **"Run new"**

## 🔧 When to Restart What

### Restart App Service When:
- ✅ Changed environment variables
- ✅ Deployed new code
- ✅ App is not responding
- ✅ Memory issues
- ✅ Configuration changes

### Re-run Pipeline When:
- ✅ Failed deployment
- ✅ Want to deploy latest code
- ✅ Testing deployment process
- ✅ Pipeline configuration changed

## 📊 Verification After Restart

### Check App Service:
1. Go to: Overview → URL
2. Verify: App loads correctly
3. Check: Application Insights (if enabled)
4. Review: Log Stream for any errors

### Check Pipeline:
1. Monitor: Pipeline execution
2. Review: Logs for each stage
3. Verify: Deployment success
4. Check: Test results

## ⚡ Quick Restart Commands

### PowerShell (if Azure CLI installed):
```powershell
# Restart app service
az webapp restart --name "playwright-cucumber-tests" --resource-group "your-rg"

# Check app status
az webapp show --name "playwright-cucumber-tests" --resource-group "your-rg" --query "state"
```

### Verify Restart:
```powershell
# Check if app is running
Invoke-WebRequest -Uri "https://playwright-cucumber-tests.azurewebsites.net" -Method Head
```

## 🚨 Troubleshooting

### If Restart Fails:
1. Check: Resource quotas
2. Verify: Service health in Azure Portal
3. Review: Activity logs
4. Contact: Azure support if needed

### If Pipeline Fails:
1. Check: Service connections
2. Verify: Permissions
3. Review: Error logs
4. Check: Agent availability
