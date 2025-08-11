# Azure App Service Environment Variables Quick Reference

## Required Environment Variables for Playwright Cucumber

| Variable Name | Variable Value | Purpose |
|---------------|----------------|---------|
| `HEADLESS` | `true` | Run browsers without GUI |
| `CI` | `true` | Enable continuous integration mode |
| `NODE_ENV` | `production` | Set Node.js environment |
| `PLAYWRIGHT_BROWSERS_PATH` | `/tmp/playwright-browsers` | Browser installation directory |
| `TEST_TIMEOUT` | `30000` | Test timeout in milliseconds |
| `BROWSER` | `chromium` | Default browser to use |
| `SCM_DO_BUILD_DURING_DEPLOYMENT` | `true` | Enable build during deployment |
| `ENABLE_ORYX_BUILD` | `true` | Enable Azure's Oryx build system |

## How to Add in Azure Portal

### Navigation Path:
```
Azure Portal → App Services → [Your App] → Settings → Configuration → Application settings
```

### Steps:
1. Click "+ New application setting"
2. Enter Name and Value from table above
3. Click "OK"
4. Repeat for each variable
5. Click "Save" at top
6. Click "Continue" to restart app

## Verification

After saving, you should see all 8 variables listed in the Application settings tab.

## Alternative: Bulk Add via Azure CLI

If you have Azure CLI installed:

```bash
az webapp config appsettings set --resource-group YOUR_RESOURCE_GROUP --name YOUR_APP_NAME --settings \
    HEADLESS=true \
    CI=true \
    NODE_ENV=production \
    PLAYWRIGHT_BROWSERS_PATH=/tmp/playwright-browsers \
    TEST_TIMEOUT=30000 \
    BROWSER=chromium \
    SCM_DO_BUILD_DURING_DEPLOYMENT=true \
    ENABLE_ORYX_BUILD=true
```

## Notes:
- Each change requires app restart
- Variables are case-sensitive
- Values don't need quotes in Azure Portal
- Changes take effect immediately after restart
