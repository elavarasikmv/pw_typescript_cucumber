import { Page } from 'playwright';
import logger from '../utils/logger';

export class BasePage {
  constructor(protected page: Page) {}
  
  /**
   * Navigate to a URL
   * @param url The URL to navigate to
   */
  async navigate(url: string): Promise<void> {
    logger.debug(`🌐 Navigating to: ${url}`);
    try {
      await this.page.goto(url, { waitUntil: 'domcontentloaded' });
      logger.debug(`✅ Successfully navigated to: ${url}`);
    } catch (error) {
      logger.error(`❌ Failed to navigate to ${url}: ${error}`);
      throw error;
    }
  }
  
  /**
   * Get page title
   * @returns The page title
   */
  async getTitle(): Promise<string> {
    return await this.page.title();
  }
  
  /**
   * Wait for page to be fully loaded
   */
  async waitForPageLoad(): Promise<void> {
    await this.page.waitForLoadState('networkidle');
  }
  
  /**
   * Check if element exists
   * @param selector Element selector
   * @returns True if element exists, false otherwise
   */
  async elementExists(selector: string): Promise<boolean> {
    logger.debug(`🔍 Checking if element exists: ${selector}`);
    try {
      const element = await this.page.$(selector);
      const exists = element !== null;
      logger.debug(`${exists ? '✅' : '❌'} Element ${selector}: ${exists ? 'found' : 'not found'}`);
      return exists;
    } catch (error) {
      logger.error(`❌ Error checking element ${selector}: ${error}`);
      return false;
    }
  }
  
  /**
   * Wait for element to be visible
   * @param selector Element selector
   * @param timeout Timeout in milliseconds
   */
  async waitForElement(selector: string, timeout = 10000): Promise<void> {
    await this.page.waitForSelector(selector, { state: 'visible', timeout });
  }
  
  /**
   * Take screenshot
   * @param name Screenshot name
   */
  async takeScreenshot(name: string): Promise<void> {
    await this.page.screenshot({ path: `test-results/screenshots/${name}.png`, fullPage: true });
  }
}