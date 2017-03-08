Feature: Verify Edit frame feature
  As a user
  I want to verify frame features.

@reset
@regression
Scenario Outline: Verify 'Frame' option
    Given I am on the "<social_media_screen_name>" screen
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
    | social_media_screen_name        |
    | Instagram Preview  |
  #  | Flickr Preview     |
    | CameraRoll Preview |
    
    

@reset
@regression
Scenario Outline: Verify frame applied for frame editor screen
    Given I am on the "FrameEditor" screen for "<social_media_screen_name>"
    Then I select "Kraft Frame" frame
    And I verify blue line indicator is displayed under selected frame
    And I should see the photo with the "Kraft Frame" frame
    Then I tap "Save" mark
    Then I should see the "Edit" screen
    And I should see the photo with the "Kraft Frame" frame
    
    Examples:
    | social_media_screen_name       |
    | Instagram Preview |
  #  | Flickr Preview    |
    | CameraRoll        |
    
    
@reset
@done
Scenario: Verify frame list
    Given I am on the "FrameEditor" screen for "CameraRoll"
    Then I should see the following "Frames" in the screen:
            |No Frame               |
            |Valentines Hearts Frame|
            |Valentines Pink Polka Frame|
            |Valentines Red Frame|
            |Valentines Hearts Overlay Frame|
            |Valentines Pink Watercolor Frame|
            |Valentines Red Stripes Frame|
            |White Frame|
            |Kraft Frame|
            |Floral Frame|
            |Orange Frame|
            |Polka Dots Frame|
            |Water Blue Frame|
            |Wood Bottom Frame      |
            |Gradient Frame         |
            |Sloppy Frame           |
            |Turquoise Frame        |
            |Red Frame              |
            |Green Water Color Frame|
            |Floral 2 Frame         |
            |Pink Spray Paint Frame |
             
  @reset
  @regression
Scenario: Verify all the frames are applied for frame editor screen 
    Given I am on the "FrameEditor" screen for "CameraRoll"  
    Then I verify that all the "frames" are applied successfully

@reset
@done
Scenario Outline: Verify navigation to and fro from frame editor screen successfully
    Given I am on the "FrameEditor" screen for "<social_media_screen_name>"
    Then I select "White Frame" frame
    And I should see the photo with the "White Frame" frame
    Then I tap "Save" mark
    Then I should see the "Edit" screen
    Then I tap "Frame" button
    Then I select "Red Frame" frame
    And I should see the photo with the "Red Frame" frame
    Then I tap "Save" mark
    Then I should see the "Edit" screen
    
    Examples:
    | social_media_screen_name       |
    | Instagram Preview |
  #  | Flickr Preview    |
    | CameraRoll        |
