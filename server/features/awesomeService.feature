 Feature: Awesome service

   Scenario: Add awesomeness to documents
    Given a collection "nova":"prospect"
    And I create the document '{ "name": "eli vance" }' with id "eli-vance"
    Then The document "eli-vance" has a property "awesomeness"
