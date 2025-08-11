# Azure App Service Quick Deployment Guide

## 🚀 QUICK SETUP STEPS

### 1. Azure Portal Setup
1. Go to: https://portal.azure.com
2. Create → App Service
3. Settings:
   - Name: playwright-cucumber-tests
   - Runtime: Node.js 18 LTS
   - OS: Linux
   - Plan: Free F1

### 2. Deployment Configuration
Go to: Deployment Center
- Source: GitHub
- Repository: elavarasikmv/pw_typescript_cucumber
- Branch: main
- Build: App Service Build

### 3. Application Settings
Go to: **Settings → Configuration → Application settings**

**Click "+ New application setting" for each:**

| Name | Value |
|------|-------|
| `HEADLESS` | `true` |
| `CI` | `true` |
| `NODE_ENV` | `production` |
| `PLAYWRIGHT_BROWSERS_PATH` | `/tmp/playwright-browsers` |
| `TEST_TIMEOUT` | `30000` |
| `BROWSER` | `chromium` |
| `SCM_DO_BUILD_DURING_DEPLOYMENT` | `true` |
| `ENABLE_ORYX_BUILD` | `true` |

**After adding all variables, click "Save"**

### 4. General Settings
Go to: **Settings → Configuration → General Settings**

```
Runtime stack: Node.js
Version: 18 LTS
Platform: Linux
Startup command: ./azure-startup.sh
Always On: On (if not Free tier)
HTTPS Only: On
```

**Click "Save"**

### 5. Platform Settings
- SCM Basic Auth: ON
- Runtime Version: Node.js 18
- Always On: ON (if not Free tier)

## 🔍 MONITORING

### Logs Location
- Application Logs: /home/LogFiles/
- Deployment Logs: /home/site/deployments/
- Test Results: /home/site/wwwroot/test-results/

### Log Commands
```bash
# View application logs
tail -f /home/LogFiles/nodejs_stdout.log

# View test results
cat /home/site/wwwroot/test-results/summary.txt
```

## 🚨 TROUBLESHOOTING

### Common Issues:
1. **Browsers not installing**: Check PLAYWRIGHT_BROWSERS_PATH
2. **Tests timing out**: Increase TEST_TIMEOUT
3. **Permission errors**: Ensure scripts are executable
4. **Memory issues**: Upgrade to higher tier

### Debug Commands:
```bash
# Check Node.js version
node --version

# Check installed browsers
npx playwright install --dry-run

# Test basic functionality
npm test
```

## 📊 EXPECTED RESULTS

After deployment, you should see:
- ✅ App Service running
- ✅ Test results in /test-results/
- ✅ HTML reports generated
- ✅ Screenshots on test failures

## 🔗 USEFUL LINKS

- App Service URL: https://playwright-cucumber-tests.azurewebsites.net
- Kudu Console: https://playwright-cucumber-tests.scm.azurewebsites.net
- GitHub Repo: https://github.com/elavarasikmv/pw_typescript_cucumber
