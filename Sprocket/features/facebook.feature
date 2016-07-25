Feature: Signin with facebook credentials and verify functionality

  
  @TA14379
  @reset
  @done
  Scenario: Verify Double-tap add borders to image on preview screen_facebook
    Given I am on the "Landing" screen
    Then I should see "Facebook" logo
    And I click on the "Facebook" logo
    Then I should see the "Facebook Landing" screen
    And I click on the "Sign in" button
    Then I should see the "Facebook Signin" screen
    And I enter valid credentials
    And I touch login button
    Then I wait for sometime
    Then I should see the "Facebook Photo" screen
    When I touch second photo
    Then I wait for sometime
    And I close the camera pop up
    Then I should see the "Preview" screen
    When I double tap on the picture
    Then I should see margins on top and bottom
    Then I double tap on the picture
    Then I should see the original image without margins


  @TA14379
  @reset
  @done
  Scenario: Verify facebook photo screen and the buttons present
    Given I am on the "Landing" screen
    Then I should see "Facebook" logo
    And I click on the "Facebook" logo
    Then I should see the "Facebook Landing" screen
    And I click on the "Sign in" button
    Then I should see the "Facebook Signin" screen
    And I enter valid credentials
    And I touch login button
    Then I should see the "Facebook Photo" screen
    Then I should see "Grid mode" button
    Then I should see "List mode" button
    Then I should see "Folder" button

  @done
  @TA14379
  @reset
  Scenario: Verify folder icon functionality in facebook
    Given I am on the "Landing" screen
    Then I should see "Facebook" logo
    And I click on the "Facebook" logo
    Then I should see the "Facebook Landing" screen
    And I click on the "Sign in" button
    Then I should see the "Facebook Signin" screen
    And I enter valid credentials
    And I touch login button
    Then I should see the "Facebook Photo" screen
    Then I touch "folderIcon" button
    Then I should see the "Facebook Albums" screen
    Then I wait for sometime
    And I should see "All Photos"
    And I should see other albums

  @done
  @TA14379
  @reset
  Scenario: Verify list view and grid view for facebook photos
    Given I am on the "Landing" screen
    Then I should see "Facebook" logo
    And I click on the "Facebook" logo
    Then I should see the "Facebook Landing" screen
    And I click on the "Sign in" button
    Then I should see the "Facebook Signin" screen
    And I enter valid credentials
    And I touch login button
    Then I should see the "Facebook Photo" screen
    Then I should see the photos in a grid view
    When I touch list mode button
    Then I should see the photos in list view
    When I touch grid mode button
    Then I should see the photos in a grid view


