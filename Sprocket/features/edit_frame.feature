Feature: Verify Edit frame feature
  As a user
  I want to verify frame features.

@done
Scenario: Verify 'Frame' option
    Given I am on the "CameraRoll Preview " screen
    When I tap "Edit" button
    Then I am on the "Edit" screen
    Then I tap "Frame" button
    Then I should see the "Frame Editor" screen
    Then I select "frame_0" frame
    And I verify blue line indicator is displayed under selected "frame"
    And I should see the photo with the "frame_0" frame
    Then I tap "Close" mark
    Then I should see the "Edit" screen
    And I should see the photo with no "frame"

@regression
Scenario Outline: Verify frame applied for frame editor screen
    Given I am on the "FrameEditor" screen for "<social_media_screen_name>"
    Then I select "frame_0" frame
    And I verify blue line indicator is displayed under selected "frame"
    And I should see the photo with the "frame_0" frame
    Then I tap "Save" mark
    Then I should see the "Edit" screen
    And I should see the photo with the "frame_0" frame
    
    Examples:
    | social_media_screen_name       |
    | Instagram Preview |
    | CameraRoll        |
    

@regression
Scenario: Verify frame list
    Given I am on the "FrameEditor" screen for "CameraRoll"
    Then I should see the following "Frames" in the screen:
            |No Frame                   |
            |Hearts Overlay Frame       |
            |Sloppy Frame               | 
            |Rainbow Frame              |
            |White Frame                |
            |Stars Overlay Frame        |
            |Polka Dots Frame           |
            |Grey Shadow Frame          |
            |Pink Triangle Frame        |
            |Floral 2 Frame             |
            |Blue Watercolor Frame      |
            |Floral Overlay Frame       |
            |Red Frame                  |
            |Gradient Frame             |
            |Turquoise Frame            |
            |Dots Overlay Frame         |
            |Kraft Frame                |
            |White Bar Frame            |
            |Pink Spray Paint Frame     |
            |White Full Frame           |
            
            
@localization
Scenario: Verify additional frames for region Australia
    Given  I am on the "CameraRollLanding" screen
    Then I open cameraroll	
    When I touch second photo
    Then I should see the "CameraRoll Preview" screen
    And I tap the "Edit" button
    Then I am on the "Edit" screen
    Then I tap "Frame" button
    Then I should see the "Frame Editor" screen
    Then I should see the following "Frames" in the screen:
            |Australia Amplify 1 Frame  |
            |Australia Amplify 3 Frame  |
            
            
@regression
Scenario: Verify all the frames are applied for frame editor screen 
    Given I am on the "FrameEditor" screen for "CameraRoll"  
    Then I verify that all the "frames" are applied successfully

@done
Scenario Outline: Verify navigation to and fro from frame editor screen successfully
    Given I am on the "FrameEditor" screen for "<social_media_screen_name>"
    Then I select "frame_1" frame
    And I should see the photo with the "frame_1" frame
    Then I tap "Save" mark
    Then I should see the "Edit" screen
    Then I tap "Frame" button
    Then I select "frame_3" frame
    And I should see the photo with the "frame_3" frame
    Then I tap "Save" mark
    Then I should see the "Edit" screen
    
    Examples:
    | social_media_screen_name       |
    | Instagram Preview |
    | CameraRoll        |
