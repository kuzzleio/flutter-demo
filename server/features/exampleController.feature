 Feature: Example controller

   Scenario: Test info route
    Given I log into Kuzzle as user "alyx" with password "password"
    When I call the plugin route "example":"info"
    Then I should receive a text result containing "Hello from example:info. Current user id: alyx"
