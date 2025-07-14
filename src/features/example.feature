Feature: Example Feature
  As a user
  I want to visit a website
  So I can test my Cucumber Playwright framework

  Scenario: Visit Google
    Given I am on the Google homepage
    When I search for "cucumber playwright typescript"
    Then I should see search results

  Scenario: Visit GitHub
    Given I am on the GitHub homepage
    Then I should see the GitHub logo