Feature: Verify multiselect feature
  As a signed in user
  I should be able to select multiple images and verify different social media

  @smoke
  @done
  @regression
  Scenario: Verify image multi select from camera Roll
    Given I am on the "CameraRoll Photo" screen
    And I touch "Select"
    Then I should see the multiselect option enabled
    Then I select "2" photos
    And I should see the number of photos selected as "2"
    And I touch "Cancel"
    And I touch "Select"
    Then I select "3" photos
    And I should see the number of photos selected as "3"
    Then I tap on the multi selected number  
    Then I should see the "CameraRoll Preview" screen
    And I should see "cancel" button
    And I should see "Edit" button
    Then I should see "Print" button
    And I should see "Share" button
    And I should see "Download" button
    And I should see the count of images and checkmark circle in each page when swipe "left"
    And I should see the count of images and checkmark circle in each page when swipe "right"

  @done
  @regression
  Scenario: Verify 10 images can be selected without app crash
    Given I am on the "Instagram Photos" screen
    And I touch "Select"
    Then I should see the multiselect option enabled
    Then I select "10" photos
    And I should see the number of photos selected as "10"
    Then I tap on the multi selected number  
    Then I should see the "CameraRoll Preview" screen
    And I should see the count of images and checkmark circle in each page when swipe "left"
    And I should see the count of images and checkmark circle in each page when swipe "right"
    
    
  @done
  @regression
  Scenario: Verify multiselect with different social media
    Given I am on the "Instagram Photos" screen
    And I touch "Select"
    Then I should see the multiselect option enabled
    Then I select "3" photos
    And I should see the number of photos selected as "3" 
    Then I swipe to see "CameraRoll Photo" screen
    Then I wait for some time
    Then I select "3" photos
    And I should see the number of photos selected as "6"
    Then I tap on the multi selected number  
    Then I should see the "CameraRoll Preview" screen
    And I should see the count of images and checkmark circle in each page when swipe "left"
    And I should see the count of images and checkmark circle in each page when swipe "right"

  @done
  @regression
Scenario: Verify preview -Drawer multiselect
    Given I am on the "CameraRoll Photo" screen
    And I touch "Select"
    Then I should see the multiselect option enabled
    Then I select "3" photos
    And I should see the number of photos selected as "3"
    Then I tap on the multi selected number  
    Then I am on the "CameraRoll Preview" screen
    Then I should see "PreviewBardots" button
    Then I tap "PreviewBardots" button
    Then I should see the preview-drawer "slides up"
    And I should see "Print Queue" with "0" items and a right arrow
    Then I tap "Print Queue" mark
    Then I verify the "content" of the popup message for "No Prints" 
    And I should see the button "OK"
    And I touch "OK"
    Then I tap "PreviewBardots" button
    Then I should see the preview-drawer "closes"


    