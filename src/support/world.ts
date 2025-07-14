import { World, IWorldOptions, setWorldConstructor } from '@cucumber/cucumber';
import { Browser, BrowserContext, Page, chromium, firefox, webkit } from 'playwright';
import { expect } from '@playwright/test';

export interface CustomWorld extends World {
  browser: Browser;
  context: BrowserContext;
  page: Page;
  testName?: string;
}

export class PlaywrightWorld extends World implements CustomWorld {
  browser!: Browser;
  context!: BrowserContext;
  page!: Page;
  testName?: string;

  constructor(options: IWorldOptions) {
    super(options);
    this.testName = options.pickle.name.replace(/\W/g, '-');
  }

  async init() {
    const browserType = this.parameters.browser || 'chromium';
    const isHeadless = process.env.HEADLESS !== 'false';
    
    switch (browserType) {
      case 'firefox':
        this.browser = await firefox.launch({ headless: isHeadless });
        break;
      case 'webkit':
        this.browser = await webkit.launch({ headless: isHeadless });
        break;
      default:
        this.browser = await chromium.launch({ headless: isHeadless });
        break;
    }
    
    this.context = await this.browser.newContext({
      viewport: { width: 1280, height: 720 },
      recordVideo: { dir: 'test-results/videos/' },
    });
    
    this.page = await this.context.newPage();
    
    // Add expect to make it available in step definitions
    this.context.expect = expect;
  }
}

setWorldConstructor(PlaywrightWorld);