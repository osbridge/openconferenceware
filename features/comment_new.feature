Feature: Comment new
  In order to display the new comment form
  As someone
  I want to see the comments form at appropriate times

  Scenario Outline: Display comments form
    Given I am interested in a proposal for a "<kind>" event
    And the settings allow comments after the deadline: "<accept_after_deadline>"
    And the event is accepting comments if after the deadline: "<accepting>"
    When I visit the proposal
    Then the comments form is displayed: "<displayed>"

    Examples:
      | kind   | accept_after_deadline | accepting | displayed |
      | open   | N                     |           | Y         |
      | open   | Y                     | N         | Y         |
      | open   | Y                     | Y         | Y         |
      | closed | N                     |           | N         |
      | closed | Y                     | N         | N         |
      | closed | Y                     | Y         | Y         |

