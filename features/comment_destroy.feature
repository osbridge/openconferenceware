Feature: Comment destroy
  In order to destroy a comment
  As someone
  I want to destroy it when allowed

  Scenario: Destroy a comment as an admin
    Given I am logged in as "aaron"
    When I am on a proposal with comments
    Then I should be able to destroy 2 comments
    And I destroy a comment
    And I should get a "success" notification
    And I am on a proposal with comments
    And I should be able to destroy 1 comments

  Scenario: Cannot destroy a comment as non-admin
    Given I am logged in as "quentin"
    When I am on a proposal with comments
    Then I should be able to destroy 0 comments
    And I destroy a comment
    And I should get a "failure" notification
