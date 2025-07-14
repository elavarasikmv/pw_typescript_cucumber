const common = {
  requireModule: ['ts-node/register'],
  require: ['src/step-definitions/**/*.ts', 'src/support/**/*.ts'],
  paths: ['src/features/**/*.feature'],
  format: [
    'summary',
    'progress-bar',
    'json:test-results/cucumber-report.json',
    'html:test-results/cucumber-report.html'
  ],
  formatOptions: { snippetInterface: 'async-await' },
  publishQuiet: true
};

module.exports = {
  default: {
    ...common
  },
  chrome: {
    ...common,
    worldParameters: { browser: 'chromium' }
  },
  firefox: {
    ...common,
    worldParameters: { browser: 'firefox' }
  },
  webkit: {
    ...common,
    worldParameters: { browser: 'webkit' }
  }
};