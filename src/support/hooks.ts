import { Before, After, BeforeAll, AfterAll, Status } from '@cucumber/cucumber';
import { PlaywrightWorld } from './world';
import fs from 'fs';
import path from 'path';
import logger from '../utils/logger';

// Ensure test results directory exists
BeforeAll(async function() {
  const dirs = ['test-results', 'test-results/screenshots', 'test-results/videos', 'logs'];
  
  logger.info('🔧 Setting up test environment...');
  
  for (const dir of dirs) {
    if (!fs.existsSync(dir)) {
      fs.mkdirSync(dir, { recursive: true });
      logger.debug(`📁 Created directory: ${dir}`);
    }
  }
  
  logger.info('✅ Test environment setup completed');
  logger.info(`🌍 Environment: ${process.env.NODE_ENV || 'development'}`);
  logger.info(`🖥️ Headless mode: ${process.env.HEADLESS || 'true'}`);
  logger.info(`🌐 Browser: ${process.env.BROWSER || 'chromium'}`);
});

Before({ timeout: 30000 }, async function(this: PlaywrightWorld, scenario) {
  const testName = this.testName || scenario.pickle.name;
  const startTime = Date.now();
  
  logger.testStart(testName, scenario.pickle.name);
  logger.info(`🚀 Initializing browser for: ${testName}`);
  
  try {
    await this.init();
    const duration = Date.now() - startTime;
    logger.info(`✅ Browser initialized successfully in ${duration}ms`);
  } catch (error) {
    logger.error(`❌ Failed to initialize browser: ${error}`);
    throw error;
  }
});

After(async function(this: PlaywrightWorld, scenario) {
  const testName = this.testName || scenario.pickle.name;
  const status = scenario.result?.status === Status.PASSED ? 'PASSED' : 'FAILED';
  const duration = scenario.result?.duration?.nanos ? Math.round(scenario.result.duration.nanos / 1000000) : undefined;
  
  // Take screenshot if scenario failed
  if (scenario.result?.status === Status.FAILED && this.page) {
    try {
      const screenshotPath = path.join('test-results/screenshots', `${this.testName || 'test'}-failure.png`);
      await this.page.screenshot({ path: screenshotPath, fullPage: true });
      
      logger.screenshot(screenshotPath, testName);
      
      // Attach screenshot to report
      const screenshot = fs.readFileSync(screenshotPath);
      this.attach(screenshot, 'image/png');
    } catch (error) {
      logger.error(`📸 Failed to take screenshot: ${error}`);
    }
  }
  
  // Log test completion
  logger.testEnd(testName, status, duration);
  
  // Close browser resources
  try {
    if (this.page) await this.page.close();
    if (this.context) await this.context.close();
    if (this.browser) await this.browser.close();
    logger.debug(`🧹 Browser resources cleaned up for: ${testName}`);
  } catch (error) {
    logger.error(`❌ Failed to cleanup browser resources: ${error}`);
  }
});

AfterAll(async function() {
  logger.info('🏁 Test suite completed');
  logger.info('📊 Check logs directory for detailed execution logs');
});