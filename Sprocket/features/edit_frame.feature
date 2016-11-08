Feature: Verify Edit frame feature
  As a user
  I want to verify frame features.

@reset
@TA15656
Scenario Outline: Verify 'Frame' option
    Given I am on the "<screen_name>" screen
    When I tap "Edit" button
    Then I am on the "Edit" screen
    Then I tap "Frame" button
    Then I should see the "Frame Editor" screen
    Then I select "Turquoise Frame" frame
    And I verify blue line indicator is displayed under selected frame
    And I should see the photo with the "Turquoise Frame" frame
    Then I tap "Close" mark
    Then I should see the "Edit" screen
    And I should see the photo with no "frame"
    
    Examples:
    | screen_name        |
    | Instagram Preview  |
    | Flickr Preview     |
    | CameraRoll Preview |
    
    

@reset
@TA14498
@TA15656
Scenario Outline: Verify frame applied for frame editor screen
    Given I am on the "FrameEditor" screen for "<screen_name>"
    Then I select "Pink Frame" frame
    And I verify blue line indicator is displayed under selected frame
    And I should see the photo with the "Pink Frame" frame
    Then I tap "Save" mark
    Then I should see the "Edit" screen
    And I should see the photo with the "Pink Frame" frame
    
    Examples:
    | screen_name       |
    | Instagram Preview |
    | Flickr Preview    |
    | CameraRoll        |
    
    
@reset
@TA15656
Scenario: Verify frame list
    Given I am on the "FrameEditor" screen for "CameraRoll"
    Then I should see the following "Frames" in the screen:
            |No Frame               |
            |Turquoise Frame        |
            |Pink Spray Paint Frame |
            |Water Blue Frame       |
            |White Frame            |
            |Red Frame              |
            |Floral Frame           |
            |Gradient Frame         |
            |Green Spray Paint Frame|
            |Polka Dots Frame       |
            |Green Water Color Frame|
            |Pink Frame             |
            |Blue Frame             |
            |Floral Frame           |
            |Blue Gradient Frame    |
            |Purple Frame           |
  
  @reset
@TA15656
Scenario: Verify all the frames are applied for frame editor screen 
    Given I am on the "FrameEditor" screen for "CameraRoll"  
    Then I verify that all the "frames" are applied successfully

@reset
@TA15656
Scenario Outline: Verify navigation to and fro from frame editor screen successfully
    Given I am on the "FrameEditor" screen for "<screen_name>"
    Then I select "White Frame" frame
    And I should see the photo with the "Pink Frame" frame
    Then I tap "Save" mark
    Then I should see the "Edit" screen
    Then I tap "Frame" button
    Then I select "Blue Frame" frame
    And I should see the photo with the "Blue Frame" frame
    Then I tap "Save" mark
    Then I should see the "Edit" screen
    
    Examples:
    | screen_name       |
    | Instagram Preview |
    | Flickr Preview    |
    | CameraRoll        |
