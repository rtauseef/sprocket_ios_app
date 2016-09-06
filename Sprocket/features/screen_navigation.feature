Feature: Verify screen navigation
  As a user I want to check default screens and other screen navigation




  @reset
  @done
Scenario: Verify camera roll navigation
Given I am on the "Landing" screen
And I tap "CameraRoll"
And I touch the Camera Roll button
When I touch Authorize
Then I should see the "CameraRoll Photo" screen
Then I touch "folderIcon" button
Then I should see the camera roll albums
Then I touch Camera Roll Image
And I should see the camera roll photos
When I touch a photos in Camera Roll photos
Then I should see the "CameraRoll Preview" screen
