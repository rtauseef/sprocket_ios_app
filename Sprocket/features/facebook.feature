Feature: Signin with facebook credentials and verify functionality

  @reset
  @fbtest
  @TA14209
  Scenario: Navigate to safari from app
    Given  I am on the "Landing" screen
    Then I tap "Facebook"
    Then I wait for sometime
    Then I should navigate to facebook screen
    Then I touch "Sign in" button
    Then I wait for sometime



  @fbtest
  @TA14209
  Scenario: Login to facebook from safari
    Given  I am on the safari screen
    And I fill the form with valid credentials for facebook
    Then I wait for sometime
    Then I click ok in confirm dialog

  @fbtest
  @TA14209
  Scenario: Verify Double-tap add borders to image on preview screen_facebook
    Given  I am on the "Landing" screen
    Then I tap "Facebook"
    Then I wait for sometime
    Then I touch "folderIcon" button
    Then I should see the "Facebook Albums" screen
    And I select an album
    When I touch second photo
    Then I wait for sometime
    And I close the camera pop up
    Then I should see the "Preview" screen
    When I double tap on the picture
    Then I wait for sometime
    Then I should see margins on top and bottom
    Then I double tap on the picture
    Then I should see the original image without margins

  @fbtest
  @TA14209
  Scenario: Verify facebook photo screen and the buttons present
    Given  I am on the "Landing" screen
    Then I tap "Facebook"
    Then I wait for sometime
    Then I should see the "Facebook Photo" screen
    Then I should see "Grid mode" button
    Then I should see "List mode" button
    Then I should see "Folder" button

  @fbtest
  @TA14209
  Scenario: Verify folder icon functionality in facebook
    Given  I am on the "Landing" screen
    Then I tap "Facebook"
    Then I wait for sometime
    Then I should see the "Facebook Photo" screen
    Then I touch "folderIcon" button
    Then I should see the "Facebook Albums" screen
    Then I wait for sometime
    And I should see "All Photos"
    And I should see other albums

  @fbtest
  @TA14209
  Scenario: Verify list view and grid view for facebook photos
    Given  I am on the "Landing" screen
    Then I tap "Facebook"
    Then I wait for sometime
    Then I should see the "Facebook Photo" screen
    Then I should see the photos in a grid view
    When I touch list mode button
    Then I should see the photos in list view
    When I touch grid mode button
    Then I should see the photos in a grid view


