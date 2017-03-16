Feature: Verify Edit screen
  As a user
  I want to verify Edit features.

@reset
@TA17012
Scenario Outline: Verify Edit screen
    Given I am on the "<social_media_screen_name>" screen
    When I tap "Edit" button
    Then I should see the "Edit" screen
    Then I should see "Filter" option
    Then I should see "Frame" option
    Then I should see "Sticker" option
    Then I should see "Text" option
    Then I should see "Crop" option
    Then I should see "Adjustment" option
    Then I should see "Close" mark
    Then I should see "Check" mark
    
    Examples:
    | social_media_screen_name|
    | Instagram Preview  |
   # | Flickr Preview     |
    | CameraRoll Preview |
    
    
@reset
@regression
Scenario Outline: Verify close button for edit screen
    Given I am on the "<social_media_screen_name>" screen
    When I tap "Edit" button
    Then I should see the "Edit" screen
    When I tap "Close" mark
    Then I should see the "<social_media_screen_name>" screen
    
    Examples:
    | social_media_screen_name|
    | Instagram Preview       |
   # | Flickr Preview     |
    | CameraRoll Preview |


 