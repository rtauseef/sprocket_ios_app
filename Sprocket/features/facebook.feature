Feature: Signin with facebook credentials and verify features 

 @reset
 @appium
 @fbtest
  Scenario: Signin to Facebook
    Given I am on the Landing screen
    Then I should see the "Facebook" Logo
    When I touch the "Facebook" Logo
    And I touch signin button
    And I login to facebook

 @appium
 @fbtest
 @ios8
 @fbtest
 Scenario: Signin to Facebook
      Given I login to facebook through safari
      

@fbtest
Scenario: Verify Double-tap add borders to image on preview screen_facebook
    Given I am on the "Landing" screen
    Then I should see "Facebook" logo
    And I click on the "Facebook" logo
    Then I should see the "Facebook Photo" screen
    When I touch second photo
    Then I wait for sometime
    And I close the camera pop up
    Then I should see the "Facebook Preview" screen
    When I double tap on the picture
    Then I should see margins on top and bottom
    Then I double tap on the picture
    Then I should see the original image without margins


  @fbtest
  Scenario: Verify facebook photo screen and the buttons present
    Given I am on the "Landing" screen
    Then I should see "Facebook" logo
    And I click on the "Facebook" logo
    Then I should see the "Facebook Photo" screen
    Then I should see "Folder" button

  @fbtest
  Scenario: Verify folder icon functionality in facebook
    Given I am on the "Landing" screen
    Then I should see "Facebook" logo
    And I click on the "Facebook" logo
    Then I should see the "Facebook Photo" screen
    Then I touch "folderIcon" button
    Then I should see the "Facebook Albums" screen
    Then I wait for sometime
    And I should see "All Photos"
    And I should see other albums

  @fbtest
  @pinch
  Scenario: Verify list view and grid view for facebook photos
    Given I am on the "Landing" screen
    Then I should see "Facebook" logo
    And I click on the "Facebook" logo
    Then I should see the "Facebook Photo" screen
    When I pinch "in" on the picture 
    Then I should see the photos in list view
    When I pinch "out" on the picture 
    Then I should see the photos in a grid view
