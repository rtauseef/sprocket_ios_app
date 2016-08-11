Feature: Verify Edit sticker feature
  As a user
  I want to verify sticker features.

@reset
@TA14499
Scenario Outline: Verify 'Sticker' option
    Given I am on the "<screen_name>" screen
    When I tap "Edit" button
    Then I should see the "Edit" screen
    Then I tap "Sticker" button
    Then I select "sticker"
    #And I verify blue line indicator is displayed under selected sticker
    Then I tap "Save" mark
    Then I should see the "Edit" screen
    And I should see the photo with the "sticker"
    Then I tap "Close" mark
    Then I should see the "Preview" screen
    
    Examples:
    | screen_name        |
    | Preview            |
    | Flickr Preview     |
    | CameraRoll Preview |
    

    
    
    
    
