Feature: Comment create
  In order to create a comment
  As someone
  I want to create a comment

  Scenario: Create a comment
    Given I am on a proposal accepting comments
    When I create a comment
    Then I should get a "success" notification
