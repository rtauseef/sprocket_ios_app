Feature: Verify preview screen from different social media
  As a signed in user
  I should be able to navigate to preview screen

  @regression
  Scenario: Navigate to preview screen via instagram
    Given I am on the "Instagram Photos" screen
    When I touch second photo
    Then I should see the "Instagram Preview" screen

  @regression
  Scenario: Verify preview screen for instagram
    Given I am on the "Instagram Preview" screen
    Then I should see "camera" button
    And I should see "cancel" button
    And I should see "Edit" button
    Then I should see "Print" button
    And I should see "Share" button

  @regression
  Scenario: Verify preview screen for Flickr
    Given I am on the "Flickr Preview" screen
    Then I should see "camera" button
    And I should see "cancel" button
    And I should see "Edit" button
    Then I should see "Print" button
    And I should see "Share" button

  @done
  @smoke
  Scenario: Verify preview screen for camera roll
    Given I am on the "CameraRoll Photo" screen
    And I should see the camera roll photos
    When I touch a photos in Camera Roll photos
    Then I should see the "CameraRoll Preview" screen
    And I close the camera pop up
    And I should see "camera" button
    And I should see "close" button
    And I should see "Edit" button
    And I should see "Print" button
    And I should see "Share" button

  @manual
  Scenario: Verify Double-tap add borders to image on preview screen_camera roll
    Given I am on the "CameraRoll Photo" screen
    When I touch a photos in Camera Roll photos
    Then I should see the "CameraRoll Preview" screen
    When I double tap on the picture
    Then I should see margins on top and bottom
    Then I double tap on the picture
    Then I should see the original image without margins

  @manual
  Scenario: Verify Double-tap add borders to image on preview screen_instagram
    Given I am on the "Instagram Preview" screen
    When I double tap on the picture
    Then I should not see margins on top and bottom
    Then I double tap on the picture
    Then I should see the original image with margins

  @reset
  @regression
  Scenario: Verify Double-tap add borders to image on preview screen_Flickr
    Given I am on the "Flickr Photo" screen
    When I touch second photo
    Then I should see the "Flickr Preview" screen
    When I double tap on the picture
    Then I should see margins on top and bottom
    Then I double tap on the picture
    Then I should see the original image without margins
    
  @regression
  @pinch
  Scenario: Verify pinch in-out and zoom the image on preview screen_instagram
    Given I am on the "Instagram Preview" screen
    Then I wait for some seconds
    When I pinch "in" on the picture
    Then I wait for some seconds
    Then I should see it in "bigger" size
    When I pinch "out" on the picture
    Then I wait for some seconds
    Then I should see it in "smaller" size
    #pinch not working correctly for < ios 9