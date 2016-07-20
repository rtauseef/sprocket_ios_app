Feature: Verify preview screen from different social media
  As a signed in user
  I should be able to navigate to preview screen

  @reset
  @done
  Scenario: Navigate to preview screen via instagram
    Given I am on the "Home" screen
    When I touch second photo
    Then I should see the "Preview" screen

  @reset
  @done
  Scenario: Verify preview screen for instagram
    Given I am on the "Preview" screen
    Then I should see "camera" button
    And I should see "cancel" button
    And I should see "edit" button
    Then I should see "print" button
    And I should see "share" button

  @reset
  @done
  Scenario: Verify preview screen for camera roll
    Given I am on the "CameraRollPhoto" screen
    And I should see the camera roll photos
    When I touch a photos in Camera Roll photos
    Then I should see the "Preview" screen
    And I close the camera pop up
    And I should see "camera" button
    And I should see "close" button
    And I should see "Edit" button
    And I should see "Print" button
    And I should see "Share" button

  @reset
  @done
  Scenario: Verify Double-tap add borders to image on preview screen_camera roll
    Given I am on the "CameraRollPhoto" screen
    When I touch a photos in Camera Roll photos
    Then I should see the "Preview" screen
    When I double tap on the picture
    Then I should see margins on top and bottom
    Then I double tap on the picture
    Then I should see the original image without margins

  @reset
  @done
  Scenario: Verify Double-tap add borders to image on preview screen_instagram
    Given I am on the "Preview" screen
    When I double tap on the picture
    Then I should see margins on top and bottom
    Then I double tap on the picture
    Then I should see the original image without margins

  @reset
  @done
  Scenario: Verify Double-tap add borders to image on preview screen_Flickr
    Given I am on the "FlickrPhoto" screen
    When I touch second photo
    Then I should see the "Preview" screen
    When I double tap on the picture
    Then I should see margins on top and bottom
    Then I double tap on the picture
    Then I should see the original image without margins
    
  @reset
  @TA14130
  Scenario: Verify pinch in-out and zoom the image on preview screen_instagram
    Given I am on the "Preview" screen
    Then I wait for some seconds
    When I pinch "in" on the picture
    Then I wait for some seconds
    Then I should see it in "bigger" size
    When I pinch "out" on the picture
    Then I wait for some seconds
    Then I should see it in "smaller" size
    #pinch not working correctly for < ios 9