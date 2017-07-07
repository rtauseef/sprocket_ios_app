Feature: Verify Edit screen
  As a user
  I want to verify Edit features.

@smoke
@done
Scenario: Verify Edit screen
    Given I am on the "CameraRoll Preview " screen
    When I choose "edit" option
    Then I am on the "Edit" screen
    Then I could see "autofix" option
    Then I could see "adjustment" option
    Then I could see "filter" option
    Then I could see "frame" option
    Then I could see "sticker" option
    Then I could see "brush" option
    Then I could see "text" option
    Then I could see "crop" option
    Then I could see "close" option
    Then I could see "check" option
    

    
@regression
Scenario Outline: Verify close button for edit screen
    Given I am on the "<social_media_screen_name>" screen
    When I choose "edit" option
    Then I should see the "Edit" screen
    When I choose "close" option
    Then I should see the "<social_media_screen_name>" screen
    
    Examples:
    | social_media_screen_name|
    | Instagram Preview       |
    | CameraRoll Preview |


 