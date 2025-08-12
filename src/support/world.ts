import { World, IWorldOptions, setWorldConstructor } from '@cucumber/cucumber';
import { Browser, BrowserContext, Page, chromium, firefox, webkit } from 'playwright';
import { expect } from '@playwright/test';
import { spawn } from 'child_process';

export interface CustomWorld extends World {
  browser: Browser;
  context: BrowserContext;
  page: Page;
  testName?: string;
}

interface IWorldOptionsWithPickle extends IWorldOptions {
  pickle?: { name: string };
}

async function installBrowserIfNeeded(browserType: string = 'chromium') {
  console.log(`🔧 Checking ${browserType} browser installation...`);
  
  // Force Azure-compatible environment variables
  const isAzure = process.env.AZURE_DEPLOYMENT === 'true' || process.env.WEBSITE_SITE_NAME;
  const browserPath = isAzure ? '/home/site/wwwroot/browsers' : process.env.PLAYWRIGHT_BROWSERS_PATH || '/tmp/playwright-browsers';
  
  // Set environment variables for Azure compatibility
  process.env.PLAYWRIGHT_BROWSERS_PATH = browserPath;
  process.env.PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD = 'false';
  
  console.log(`📍 Browser path: ${browserPath}`);
  console.log(`🌍 Azure environment: ${isAzure ? 'Yes' : 'No'}`);
  
  try {
    // Try to launch browser first to check if it exists
    let testBrowser;
    const launchOptions = {
      headless: true,
      args: isAzure ? [
        '--no-sandbox',
        '--disable-setuid-sandbox',
        '--disable-dev-shm-usage',
        '--disable-gpu',
        '--no-first-run',
        '--no-zygote',
        '--single-process'
      ] : []
    };
    
    switch (browserType) {
      case 'firefox':
        testBrowser = await firefox.launch(launchOptions);
        break;
      case 'webkit':
        testBrowser = await webkit.launch(launchOptions);
        break;
      default:
        testBrowser = await chromium.launch(launchOptions);
        break;
    }
    await testBrowser.close();
    console.log(`✅ ${browserType} browser already available`);
    return true;
  } catch (error) {
    console.log(`⚠️ ${browserType} browser not available, installing...`);
    console.log(`Error details: ${error.message}`);
    
    return new Promise<boolean>((resolve) => {
      try {
        const installProcess = spawn(process.execPath, [
          require.resolve('playwright-core/cli.js'),
          'install',
          browserType,
          '--with-deps'
        ], {
          env: {
            ...process.env,
            PLAYWRIGHT_BROWSERS_PATH: browserPath,
            PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD: 'false'
          },
          stdio: 'pipe'
        });
        
        let output = '';
        let errorOutput = '';
        
        installProcess.stdout?.on('data', (data) => {
          output += data.toString();
          console.log(`Install stdout: ${data.toString().trim()}`);
        });
        
        installProcess.stderr?.on('data', (data) => {
          errorOutput += data.toString();
          console.log(`Install stderr: ${data.toString().trim()}`);
        });
        
        installProcess.on('close', (code) => {
          if (code === 0) {
            console.log(`✅ ${browserType} browser installation completed successfully`);
            resolve(true);
          } else {
            console.log(`❌ ${browserType} browser installation failed with code ${code}: ${errorOutput}`);
            resolve(false);
          }
        });
        
        installProcess.on('error', (error) => {
          console.log(`❌ ${browserType} browser installation process error: ${error.message}`);
          resolve(false);
        });
        
        // Set timeout for installation
        setTimeout(() => {
          installProcess.kill();
          console.log(`⏰ ${browserType} browser installation timed out`);
          resolve(false);
        }, 300000); // 5 minutes
        
      } catch (requireError: any) {
        console.log(`playwright-core not found, trying fallback: ${requireError.message}`);
        // Fallback: try using playwright package
        try {
          const installProcess = spawn(process.execPath, [
            require.resolve('playwright/cli.js'),
            'install',
            browserType
          ], {
            env: {
              ...process.env,
              PLAYWRIGHT_BROWSERS_PATH: browserPath
            },
            stdio: 'pipe'
          });
          
          installProcess.on('close', (code) => {
            console.log(`${browserType} browser installation (fallback) completed with code: ${code}`);
            resolve(code === 0);
          });
          
          installProcess.on('error', (error) => {
            console.log(`${browserType} browser installation (fallback) error: ${error.message}`);
            resolve(false);
          });
        } catch (fallbackError: any) {
          console.log(`Both playwright and playwright-core failed: ${fallbackError.message}`);
          resolve(false);
        }
      }
    });
  }
}

export interface CustomWorld extends World {
  browser: Browser;
  context: BrowserContext;
  page: Page;
  testName?: string;
}

interface IWorldOptionsWithPickle extends IWorldOptions {
  pickle?: { name: string };
}

export class PlaywrightWorld extends World implements CustomWorld {
  browser!: Browser;
  context!: BrowserContext;
  page!: Page;
  testName?: string;

  constructor(options: IWorldOptionsWithPickle) {
    super(options);
    this.testName = options.pickle?.name ? options.pickle.name.replace(/\W/g, '-') : undefined;
  }

  async init() {
    const browserType = this.parameters.browser || 'chromium';
    const isHeadless = process.env.HEADLESS !== 'false';
    
    // Install browser if needed before launching
    await installBrowserIfNeeded(browserType);
    
    // Azure-compatible launch options
    const isAzure = process.env.AZURE_DEPLOYMENT === 'true' || process.env.WEBSITE_SITE_NAME;
    const launchOptions = {
      headless: isHeadless,
      args: isAzure ? [
        '--no-sandbox',
        '--disable-setuid-sandbox',
        '--disable-dev-shm-usage',
        '--disable-gpu',
        '--no-first-run',
        '--no-zygote',
        '--single-process',
        '--disable-background-timer-throttling',
        '--disable-backgrounding-occluded-windows',
        '--disable-renderer-backgrounding',
        '--disable-features=TranslateUI',
        '--disable-ipc-flooding-protection'
      ] : [],
      // Explicitly set executable path for Azure
      ...(isAzure && {
        executablePath: process.env.PLAYWRIGHT_BROWSERS_PATH 
          ? `${process.env.PLAYWRIGHT_BROWSERS_PATH}/chromium_headless_shell-*/chrome-linux/headless_shell`
          : undefined
      })
    };
    
    console.log(`🚀 Launching ${browserType} browser with Azure compatibility: ${isAzure}`);
    console.log(`📍 Browser path: ${process.env.PLAYWRIGHT_BROWSERS_PATH}`);
    
    switch (browserType) {
      case 'firefox':
        this.browser = await firefox.launch(launchOptions);
        break;
      case 'webkit':
        this.browser = await webkit.launch(launchOptions);
        break;
      default:
        this.browser = await chromium.launch(launchOptions);
        break;
    }
    
    this.context = await this.browser.newContext({
      viewport: { width: 1280, height: 720 },
      recordVideo: { dir: 'test-results/videos/' },
    });
    
    this.page = await this.context.newPage();
    
    // Add expect to make it available in step definitions
    // You can access expect via the world instance: this.expect
    (this as any).expect = expect;
  }
}

setWorldConstructor(PlaywrightWorld);