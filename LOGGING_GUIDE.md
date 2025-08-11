# 📊 Logging Framework Documentation

## Overview

Your Playwright Cucumber TypeScript framework now includes a comprehensive logging system using **Winston** with the following features:

- **Daily rotating file logs** with automatic cleanup
- **Multiple log levels** and specialized log files
- **Custom logging methods** for test automation
- **Azure App Service compatibility**
- **Cross-platform support** (Windows/Linux)

---

## 📂 Log Files Structure

```
logs/
├── application-YYYY-MM-DD.log      # All application logs
├── error-YYYY-MM-DD.log            # Error logs only
├── test-execution-YYYY-MM-DD.log   # Test execution summary
├── exceptions.log                  # Uncaught exceptions
└── rejections.log                  # Unhandled promise rejections
```

### Log Retention
- **Application logs**: 14 days
- **Error logs**: 30 days  
- **Test execution logs**: 7 days
- **Max file size**: 20MB (50MB for test execution)

---

## 🚀 Usage

### Running Tests with Logging

```bash
# Run tests with debug logging
npm run test:debug

# Run tests with verbose output + debug logs
npm run test:verbose

# Run tests and generate logs (same as test:debug)
npm run test:logs
```

### Viewing Logs

```bash
# List all log files
npm run logs:list

# View latest log file
npm run logs:latest

# View application logs
npm run logs:app

# View logs with PowerShell script
.\logs.ps1 list
.\logs.ps1 latest
.\logs.ps1 app
```

### Log Management

```bash
# Clean all logs
npm run logs:clean

# View log using simple PowerShell script
.\logs.ps1 [latest|list|app]
```

---

## 🎯 Log Levels

| Level | Description | Use Case |
|-------|-------------|----------|
| `error` | Critical errors | Test failures, system errors |
| `warn` | Warnings | Timeouts, fallbacks |
| `info` | General information | Test start/end, navigation |
| `debug` | Detailed debugging | Step execution, element checks |

### Setting Log Level

```bash
# Environment variable
export LOG_LEVEL=debug   # Linux/Mac
set LOG_LEVEL=debug      # Windows CMD

# NPM scripts (recommended)
npm run test:debug       # Sets LOG_LEVEL=debug automatically
```

---

## 📝 Custom Logging Methods

The logger includes specialized methods for test automation:

### Test Lifecycle
```typescript
logger.testStart(testName, scenario?)
logger.testEnd(testName, status, duration?)
```

### Step Tracking
```typescript
logger.stepStart(stepName)
logger.stepEnd(stepName, status)
```

### Browser Actions
```typescript
logger.pageNavigation(url, testName)
logger.browserAction(action, element, testName)
logger.screenshot(filePath, testName)
```

### Assertions
```typescript
logger.assertion(assertion, result, testName)
```

---

## 🔧 Integration Examples

### Step Definitions
```typescript
import logger from '../utils/logger';

Given('I am on the Google homepage', async function(this: PlaywrightWorld) {
  const testName = this.testName || 'Google Test';
  logger.stepStart('Navigate to Google homepage');
  
  // Your test code here
  await page.goto('https://www.google.com');
  
  logger.stepEnd('Navigate to Google homepage', 'PASSED');
});
```

### Page Objects
```typescript
import logger from '../utils/logger';

export class BasePage {
  async navigate(url: string): Promise<void> {
    logger.debug(`🌐 Navigating to: ${url}`);
    
    try {
      await this.page.goto(url);
      logger.debug(`✅ Successfully navigated to: ${url}`);
    } catch (error) {
      logger.error(`❌ Failed to navigate to ${url}: ${error}`);
      throw error;
    }
  }
}
```

### Hooks
```typescript
import logger from '../utils/logger';

Before(async function(this: PlaywrightWorld, scenario) {
  const testName = scenario.pickle.name;
  logger.testStart(testName);
  logger.info(`🚀 Initializing browser for: ${testName}`);
  
  // Setup code
});

After(async function(this: PlaywrightWorld, scenario) {
  const status = scenario.result?.status === Status.PASSED ? 'PASSED' : 'FAILED';
  const duration = scenario.result?.duration?.nanos ? 
    Math.round(scenario.result.duration.nanos / 1000000) : undefined;
  
  logger.testEnd(testName, status, duration);
});
```

---

## 🔷 Azure Integration

### Azure App Service Logging
The logger automatically detects Azure App Service environment and:
- Adds stdout transport for Azure log streaming
- Includes Azure-specific log formatting
- Writes to both file system and Azure logs

### Viewing Azure Logs
```bash
# In Azure Cloud Shell or SSH
tail -f /home/site/wwwroot/logs/application-$(date +%Y-%m-%d).log

# Using Azure CLI
az webapp log tail --name your-app-name --resource-group your-rg
```

---

## 🛠️ Log Monitoring Scripts

### PowerShell Script (Windows)
```powershell
# View logs
.\logs.ps1 latest    # Latest log file
.\logs.ps1 list      # All log files
.\logs.ps1 app       # Application logs

# NPM scripts
npm run logs:list    # List all logs
npm run logs:latest  # View latest
npm run logs:clean   # Clean logs
```

### Bash Script (Linux/Azure)
```bash
# For Azure environments
./log-monitor.sh view latest
./log-monitor.sh clean
./log-monitor.sh backup
```

---

## 📊 Log Output Examples

### Test Execution Log
```
2025-08-10 21:53:48 info: 🚀 TEST START: Visit Google - Visit Google
2025-08-10 21:53:48 info: 🚀 Initializing browser for: Visit Google
2025-08-10 21:53:53 info: ✅ Browser initialized successfully in 4460ms
2025-08-10 21:54:12 info: ✅ TEST PASSED: Visit Google (462ms)
```

### Application Debug Log
```
2025-08-10 21:53:53 debug: 📝 STEP: Navigate to Google homepage
2025-08-10 21:53:53 debug: 🌐 Navigating to: https://www.google.com
2025-08-10 21:53:54 debug: ✅ Successfully navigated to: https://www.google.com
2025-08-10 21:53:56 debug: ✓ ASSERTION: Google Homepage Test -> Page title contains "Google"
2025-08-10 21:53:56 debug: ✓ STEP PASSED: Navigate to Google homepage
```

---

## 🎨 Log Formatting

### Console Output (Colored)
- **Error**: Red text
- **Warning**: Yellow text  
- **Info**: Green text
- **Debug**: Blue text

### File Output (Plain Text)
- Timestamp: `YYYY-MM-DD HH:mm:ss:ms`
- Level: `[ERROR|WARN|INFO|DEBUG]`
- Message with emojis for easy scanning

---

## ⚙️ Configuration

### Environment Variables
```bash
LOG_LEVEL=debug     # Set log level (error|warn|info|debug)
HEADLESS=true       # Browser mode (affects logging verbosity)
BROWSER=chromium    # Browser type (logged in setup)
```

### Customization
Edit `src/utils/logger.ts` to modify:
- Log levels and colors
- File rotation settings
- Custom log methods
- Output formats

---

## 🚨 Troubleshooting

### Common Issues

1. **No logs generated**
   ```bash
   # Check if logs directory exists
   mkdir -p logs
   
   # Run with debug
   npm run test:debug
   ```

2. **Permission errors**
   ```bash
   # Windows PowerShell execution policy
   Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
   ```

3. **Large log files**
   ```bash
   # Clean old logs
   npm run logs:clean
   
   # Check log sizes
   npm run logs:list
   ```

### Log Rotation
Logs automatically rotate daily and clean up based on retention policies. Manual cleanup:
```bash
find ./logs -name "*.log" -mtime +7 -delete  # Linux
npm run logs:clean                            # Cross-platform
```

---

## 📈 Best Practices

1. **Use appropriate log levels**
   - `error`: Only for failures and critical issues
   - `info`: Test lifecycle, navigation, important events
   - `debug`: Detailed step execution, element interactions

2. **Include context in log messages**
   ```typescript
   logger.info(`✅ Test completed: ${testName} in ${duration}ms`);
   ```

3. **Use custom methods for consistency**
   ```typescript
   // Good
   logger.pageNavigation(url, testName);
   
   // Instead of
   logger.info(`Navigating to ${url}`);
   ```

4. **Monitor log file sizes**
   ```bash
   npm run logs:list  # Check file sizes regularly
   ```

5. **Clean logs regularly in CI/CD**
   ```bash
   npm run logs:clean  # Add to pipeline cleanup
   ```

---

## 🔗 Integration with CI/CD

### GitHub Actions
```yaml
- name: Run tests with logging
  run: npm run test:logs

- name: Upload logs
  if: always()
  uses: actions/upload-artifact@v3
  with:
    name: test-logs
    path: logs/
```

### Azure DevOps
```yaml
- script: npm run test:logs
  displayName: 'Run tests with logging'

- task: PublishBuildArtifacts@1
  condition: always()
  inputs:
    pathToPublish: 'logs'
    artifactName: 'test-logs'
```

---

**✅ Your logging framework is now fully implemented and ready for production use!**
