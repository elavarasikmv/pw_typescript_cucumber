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

Before(async function(this: PlaywrightWorld) {
  await this.init();
});

After(async function(this: PlaywrightWorld, scenario) {
  // Take screenshot if scenario failed
  if (scenario.result?.status === Status.FAILED) {
    const screenshotPath = path.join('test-results/screenshots', `${this.testName}-failure.png`);
    await this.page.screenshot({ path: screenshotPath, fullPage: true });
    
    // Attach screenshot to report
    const screenshot = fs.readFileSync(screenshotPath);
    this.attach(screenshot, 'image/png');
  }
  
  // Close browser
  await this.page.close();
  await this.context.close();
  await this.browser.close();
});