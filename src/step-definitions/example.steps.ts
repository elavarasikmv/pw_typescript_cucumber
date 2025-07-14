import { Given, When, Then } from '@cucumber/cucumber';
import { PlaywrightWorld } from '../support/world';
import { BasePage } from '../pages/BasePage';
import { expect } from '@playwright/test';

// Create a simple page object for Google
class GooglePage extends BasePage {
  async search(query: string): Promise<void> {
    await this.page.fill('input[name="q"]', query);
    await this.page.press('input[name="q"]', 'Enter');
    await this.page.waitForLoadState('networkidle');
  }
  
  async hasSearchResults(): Promise<boolean> {
    return await this.elementExists('#search');
  }
}

// Create a simple page object for GitHub
class GitHubPage extends BasePage {
  async hasGitHubLogo(): Promise<boolean> {
    return await this.elementExists('.octicon-mark-github');
  }
}

Given('I am on the Google homepage', async function(this: PlaywrightWorld) {
  const page = new BasePage(this.page);
  await page.navigate('https://www.google.com');
  const title = await page.getTitle();
  expect(title).toContain('Google');
});

When('I search for {string}', async function(this: PlaywrightWorld, query: string) {
  const googlePage = new GooglePage(this.page);
  await googlePage.search(query);
});

Then('I should see search results', async function(this: PlaywrightWorld) {
  const googlePage = new GooglePage(this.page);
  expect(await googlePage.hasSearchResults()).toBeTruthy();
});

Given('I am on the GitHub homepage', async function(this: PlaywrightWorld) {
  const page = new BasePage(this.page);
  await page.navigate('https://github.com');
  const title = await page.getTitle();
  expect(title).toContain('GitHub');
});

Then('I should see the GitHub logo', async function(this: PlaywrightWorld) {
  const githubPage = new GitHubPage(this.page);
  expect(await githubPage.hasGitHubLogo()).toBeTruthy();
});