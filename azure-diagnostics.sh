# Azure App Service Diagnostic Commands

# Enable application logging (run these in Azure Cloud Shell or local Azure CLI)

# 1. Enable application logs
az webapp log config --application-logging filesystem --resource-group YOUR_RESOURCE_GROUP --name YOUR_APP_NAME

# 2. View real-time logs
az webapp log tail --resource-group YOUR_RESOURCE_GROUP --name YOUR_APP_NAME

# 3. Download logs
az webapp log download --resource-group YOUR_RESOURCE_GROUP --name YOUR_APP_NAME

# 4. Check app service configuration
az webapp config show --resource-group YOUR_RESOURCE_GROUP --name YOUR_APP_NAME

# 5. Check startup command
az webapp config show --resource-group YOUR_RESOURCE_GROUP --name YOUR_APP_NAME --query "startupFile"

# Replace YOUR_RESOURCE_GROUP and YOUR_APP_NAME with your actual values
