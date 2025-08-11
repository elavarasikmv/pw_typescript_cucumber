const { chromium } = require('playwright');

async function runBasicWebTest() {
    console.log('🚀 Starting Basic Web Test...');
    
    let browser = null;
    try {
        // Launch browser with Azure-friendly settings
        browser = await chromium.launch({
            headless: true,
            args: [
                '--no-sandbox',
                '--disable-setuid-sandbox',
                '--disable-dev-shm-usage',
                '--disable-gpu',
                '--no-first-run',
                '--no-zygote',
                '--single-process'
            ]
        });
        
        const context = await browser.newContext({
            viewport: { width: 1280, height: 720 }
        });
        const page = await context.newPage();
        
        console.log('📄 Testing navigation to example.com...');
        await page.goto('https://example.com', { 
            waitUntil: 'networkidle',
            timeout: 30000 
        });
        
        const title = await page.title();
        console.log(`✅ Page title: ${title}`);
        
        // Check if page contains expected text
        const hasExampleText = await page.locator('text=Example Domain').isVisible();
        console.log(`✅ Example text visible: ${hasExampleText}`);
        
        // Get page URL
        const url = page.url();
        console.log(`✅ Final URL: ${url}`);
        
        // Check page load performance
        const loadTime = await page.evaluate(() => {
            return performance.timing.loadEventEnd - performance.timing.navigationStart;
        });
        console.log(`✅ Page load time: ${loadTime}ms`);
        
        console.log('✅ Basic Web Test completed successfully!');
        return { 
            success: true, 
            message: 'Basic web test passed',
            details: {
                title: title,
                url: url,
                loadTime: loadTime,
                exampleTextVisible: hasExampleText
            }
        };
        
    } catch (error) {
        console.error('❌ Basic Web Test failed:', error.message);
        return { 
            success: false, 
            error: error.message,
            stack: error.stack
        };
    } finally {
        if (browser) {
            await browser.close();
        }
    }
}

async function runGoogleSearchTest() {
    console.log('🔍 Starting Google Search Test...');
    
    let browser = null;
    try {
        browser = await chromium.launch({
            headless: true,
            args: [
                '--no-sandbox',
                '--disable-setuid-sandbox',
                '--disable-dev-shm-usage',
                '--disable-gpu'
            ]
        });
        
        const context = await browser.newContext();
        const page = await context.newPage();
        
        console.log('📄 Navigating to Google...');
        await page.goto('https://www.google.com', { waitUntil: 'networkidle' });
        
        // Handle cookie consent if present
        try {
            await page.locator('text=Accept all').click({ timeout: 5000 });
        } catch (e) {
            console.log('No cookie consent found');
        }
        
        // Search for something
        console.log('🔍 Performing search...');
        await page.fill('[name="q"]', 'Playwright testing');
        await page.press('[name="q"]', 'Enter');
        
        // Wait for results
        await page.waitForSelector('#search', { timeout: 10000 });
        
        const resultsCount = await page.locator('#search .g').count();
        console.log(`✅ Found ${resultsCount} search results`);
        
        console.log('✅ Google Search Test completed successfully!');
        return { 
            success: true, 
            message: 'Google search test passed',
            details: {
                resultsCount: resultsCount
            }
        };
        
    } catch (error) {
        console.error('❌ Google Search Test failed:', error.message);
        return { 
            success: false, 
            error: error.message 
        };
    } finally {
        if (browser) {
            await browser.close();
        }
    }
}

module.exports = { runBasicWebTest, runGoogleSearchTest };
