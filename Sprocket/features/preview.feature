Feature: Verify preview screen from different social media
  As a signed in user
  I should be able to navigate to preview screen

  @reset
  @TA13976
  Scenario: Navigate to preview screen via instagram
    Given I am on the "Home" screen
    When I touch second photo
    Then I should see the "Preview" screen

  @reset
  @TA13976
  Scenario: Verify preview screen for instagram
    Given I am on the "Preview" screen
    Then I should see "camera" button
    And I should see "cancel" button
    And I should see "edit" button
    Then I should see "print" button
    And I should see "share" button

  @reset
  @TA13976
  Scenario: Verify preview screen for camera roll
    Given I am on the "Landing" screen 
    And I tap "CameraRoll"
    And I touch the Camera Roll button
    When I touch Authorize
    Then I should see the "CameraRollPhoto" screen
    Then I touch "folderIcon" button
    Then I should see the camera roll albums
    Then I touch Camera Roll Image
    And I should see the camera roll photos
    When I touch a photos in Camera Roll photos
    Then I should see the "Preview" screen
    And I should see "camera" button
    And I should see "close" button
    And I should see "Edit" button
    And I should see "Print" button
    And I should see "Share" button

  @reset
  @TA14130
  Scenario: Verify Double-tap add borders to image on preview screen_camera roll
    Given I am on the "CameraRollAlbums" screen
    Then I touch Camera Roll Image
    And I should see the camera roll photos
    When I touch a photos in Camera Roll photos
    Then I should see the "Preview" screen
    When I double tap on the picture
    Then I should see margins on top and bottom
    Then I double tap on the picture
    Then I should see the original image without margins

  @reset
  @TA14130
  Scenario: Verify Double-tap add borders to image on preview screen_instagram
    Given I am on the "Preview" screen
    When I double tap on the picture
    Then I should see margins on top and bottom
    Then I double tap on the picture
    Then I should see the original image without margins

  @reset
  @TA14130
  Scenario: Verify Double-tap add borders to image on preview screen_Flickr
    Given I am on the "FlickrPhoto" screen
    When I touch second photo
    Then I should see the "Preview" screen
    When I double tap on the picture
    Then I should see margins on top and bottom
    Then I double tap on the picture
    Then I should see the original image without margins
