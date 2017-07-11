Feature: Verify Edit screen
  As a user
  I want to verify Edit features.

@smoke
@done
Scenario: Verify Edit screen
    Given I am on the "CameraRoll Preview " screen
    When I touch "Edit" 
    Then I am on the "Edit" screen
    Then I should see "Magic" 
    Then I should see "Adjust" 
    Then I should see "Filter" 
    Then I should see "Frame" 
    Then I should see "Sticker" 
    Then I could see "brush" option
    Then I could see "text" option
    Then I could see "crop" option
    Then I should see "Discard photo" 
    Then I could see "save" option
    

    
@regression
Scenario Outline: Verify close button for edit screen
    Given I am on the "<social_media_screen_name>" screen
    When I touch "Edit"
    Then I should see the "Edit" screen
    When I touch "Discard photo" 
    Then I should see the "<social_media_screen_name>" screen
    
    Examples:
    | social_media_screen_name|
    | Instagram Preview       |
    | CameraRoll Preview |


 