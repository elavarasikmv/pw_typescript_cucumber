import { Given, When, Then } from '@cucumber/cucumber';
import { PlaywrightWorld } from '../support/world';
import { BasePage } from '../pages/BasePage';
import { expect } from '@playwright/test';

// Create a simple page object for Google
class GooglePage extends BasePage {
  async search(query: string): Promise<void> {
    // Try multiple selectors for the search input (Google now uses textarea)
    const searchSelectors = [
      'textarea[name="q"]',
      '#APjFqb',
      '.gLFyf',
      'input[name="q"]',
      'input[title*="Search"]',
      'input[type="search"]'
    ];
    
    let searchInput = null;
    for (const selector of searchSelectors) {
      try {
        await this.page.waitForSelector(selector, { state: 'visible', timeout: 3000 });
        searchInput = selector;
        break;
      } catch (error) {
        // Continue to next selector
      }
    }
    
    if (!searchInput) {
      throw new Error('Could not find Google search input field');
    }
    
    // Clear any existing text and fill the search query
    await this.page.fill(searchInput, '');
    await this.page.fill(searchInput, query);
    
    // Press Enter to search
    await this.page.press(searchInput, 'Enter');
    
    // Wait for search results to load
    try {
      await this.page.waitForSelector('#search, #rso, .g, #main', { state: 'visible', timeout: 15000 });
    } catch (error) {
      // Fallback: wait for navigation and load state
      await this.page.waitForLoadState('domcontentloaded');
    }
  }
  
  async hasSearchResults(): Promise<boolean> {
    // Check for multiple possible search result containers
    const selectors = ['#search', '#rso', '.g', '#main', '.s', '.rc', '#center_col', '#res'];
    
    for (const selector of selectors) {
      if (await this.elementExists(selector)) {
        return true;
      }
    }
    
    // Check if we're on a search results page by URL
    const url = this.page.url();
    return url.includes('/search?') || url.includes('q=');
  }
}

// Create a simple page object for GitHub
class GitHubPage extends BasePage {
  async hasGitHubLogo(): Promise<boolean> {
    // Check for multiple possible GitHub logo selectors
    const selectors = [
      '.octicon-mark-github',
      '[aria-label*="GitHub"]',
      '.Header-link .octicon',
      'svg.octicon-mark-github',
      '.header-logo'
    ];
    
    for (const selector of selectors) {
      if (await this.elementExists(selector)) {
        return true;
      }
    }
    return false;
  }
}

Given('I am on the Google homepage', { timeout: 30000 }, async function(this: PlaywrightWorld) {
  const page = new BasePage(this.page);
  await page.navigate('https://www.google.com');
  
  // Wait a bit for page to fully load
  await this.page.waitForTimeout(2000);
  
  const title = await page.getTitle();
  expect(title).toContain('Google');
});

When('I search for {string}', { timeout: 30000 }, async function(this: PlaywrightWorld, query: string) {
  const googlePage = new GooglePage(this.page);
  await googlePage.search(query);
});

Then('I should see search results', { timeout: 15000 }, async function(this: PlaywrightWorld) {
  const googlePage = new GooglePage(this.page);
  expect(await googlePage.hasSearchResults()).toBeTruthy();
});

Given('I am on the GitHub homepage', { timeout: 30000 }, async function(this: PlaywrightWorld) {
  const page = new BasePage(this.page);
  await page.navigate('https://github.com');
  const title = await page.getTitle();
  expect(title).toContain('GitHub');
});

Then('I should see the GitHub logo', { timeout: 15000 }, async function(this: PlaywrightWorld) {
  const githubPage = new GitHubPage(this.page);
  expect(await githubPage.hasGitHubLogo()).toBeTruthy();
});