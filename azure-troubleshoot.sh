# Azure App Service Troubleshooting Commands
# Replace the resource group name with your actual one

APP_NAME="cts-vibeappwe6512-4"
SUBSCRIPTION_ID="3b1e4038-9866-4db5-b7e5-8620ca328cc5"

echo "🔍 Enabling logging for $APP_NAME..."

# Enable application logging
az webapp log config \
  --name $APP_NAME \
  --subscription $SUBSCRIPTION_ID \
  --application-logging filesystem \
  --level verbose \
  --detailed-error-messages true \
  --failed-request-tracing true \
  --web-server-logging filesystem

# Get current configuration
echo "📋 Current App Service configuration:"
az webapp config show \
  --name $APP_NAME \
  --subscription $SUBSCRIPTION_ID

# Get application settings
echo "⚙️ Current application settings:"
az webapp config appsettings list \
  --name $APP_NAME \
  --subscription $SUBSCRIPTION_ID

# View recent logs
echo "📊 Recent logs:"
az webapp log tail \
  --name $APP_NAME \
  --subscription $SUBSCRIPTION_ID

echo "✅ Logging enabled. Check Azure Portal Log Stream."
