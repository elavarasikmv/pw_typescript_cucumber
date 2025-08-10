import { Before, After, BeforeAll, AfterAll, Status } from '@cucumber/cucumber';
import { PlaywrightWorld } from './world';
import fs from 'fs';
import path from 'path';

// Ensure test results directory exists
BeforeAll(async function() {
  const dirs = ['test-results', 'test-results/screenshots', 'test-results/videos'];
  
  for (const dir of dirs) {
    if (!fs.existsSync(dir)) {
      fs.mkdirSync(dir, { recursive: true });
    }
  }
});

Before({ timeout: 30000 }, async function(this: PlaywrightWorld) {
  await this.init();
});

After(async function(this: PlaywrightWorld, scenario) {
  // Take screenshot if scenario failed
  if (scenario.result?.status === Status.FAILED && this.page) {
    try {
      const screenshotPath = path.join('test-results/screenshots', `${this.testName || 'test'}-failure.png`);
      await this.page.screenshot({ path: screenshotPath, fullPage: true });
      
      // Attach screenshot to report
      const screenshot = fs.readFileSync(screenshotPath);
      this.attach(screenshot, 'image/png');
    } catch (error) {
      console.log('Failed to take screenshot:', error);
    }
  }
  
  // Close browser
  if (this.page) await this.page.close();
  if (this.context) await this.context.close();
  if (this.browser) await this.browser.close();
});