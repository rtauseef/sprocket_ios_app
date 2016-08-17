Feature: Verify Edit frame feature
  As a user
  I want to verify frame features.

@reset
@TA14498
Scenario Outline: Verify 'Frame' option
    Given I am on the "<screen_name>" screen
    When I tap "Edit" button
    Then I am on the "Edit" screen
    Then I tap "Frame" button
    Then I should see the "Frame Editor" screen
    Then I select "frame"
    And I verify blue line indicator is displayed under selected frame
    And I should see the photo with the "frame" 
    Then I tap "Close" mark
    Then I should see the "Edit" screen
    And I should see the photo with no "frame"
    
    Examples:
    | screen_name        |
    | Preview            |
    | Flickr Preview     |
    | CameraRoll Preview |
    
    

@reset
@TA14498
Scenario Outline: Verify 'Frame' option
    Given I am on the "FrameEditor" screen for "<screen_name>"
    Then I select "frame"
    And I verify blue line indicator is displayed under selected frame
    And I should see the photo with the "frame"
    Then I tap "Save" mark
    Then I should see the "Edit" screen
    And I should see the photo with the "frame"
    
    Examples:
    | screen_name|
    | Instagram  |
    | Flickr     |
    | CameraRoll |
    
    
    
    
