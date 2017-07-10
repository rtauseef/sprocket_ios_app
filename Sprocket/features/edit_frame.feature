Feature: Verify Edit frame feature
  As a user
  I want to verify frame features.

  
  @done
  Scenario: Verify frame list
    Given I am on the "FrameEditor" screen for "CameraRoll"
    Then I should see the following "Frames" in the screen:

      |Hearts Overlay Frame       |
      |Sloppy Frame               |
      |Rainbow Frame              |
      |White Frame                |
      |Stars Overlay Frame        |
      |Polka Dots Frame           |
      |Grey Shadow Frame          |
      |Pink Triangle Frame        |
      |White Rounded Frame        |
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
      |Disney Logo Frame          | 
      |Disney Polaroid 1 Frame    |
      |Disney Polaroid 2 Frame    |

  
  @regression
  Scenario: Verify all the frames are applied for frame editor screen
    Given I am on the "FrameEditor" screen for "CameraRoll"
    Then I verify that all the "frames" are applied successfully

  
  @done
  Scenario Outline: Verify Frame Save,Close functionality
    Given I am on the "FrameEditor" screen for "<social_media_screen_name>"
    Then I select "frame_0" frame
    Then I should see the photo with the "frame_0" frame
    Then I choose "close" option
    Then I should see the "Edit" screen
    And I should see the photo with no "frame"
    Then I choose "frame" option
    Then I should see the "Frame Editor" screen
    Then I select "frame_1" frame
    Then I should see the photo with the "frame_1" frame
    Then I choose "save" option
    Then I should see the "Edit" screen
    Then I should see the photo with the "frame_1" frame


    Examples:
      | social_media_screen_name       |
      | Instagram Preview |
      | CameraRoll        |

