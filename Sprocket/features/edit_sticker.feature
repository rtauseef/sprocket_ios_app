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
    Then I should see the "Sticker Editor" screen
    Then I select "sticker"
    And I should see the photo with the "sticker"
    Then I tap "Close" mark
    Then I should see the "Edit" screen
    And I should see the photo with no "sticker"
    
    Examples:
    | screen_name        |
    | Preview            |
    | Flickr Preview     |
    | CameraRoll Preview |
    
@reset
@TA14499
Scenario Outline: Verify 'Sticker' option
    Given I am on the "StickerEditor" screen for "<screen_name>"
    Then I select "sticker"
    And I should see the photo with the "sticker"
    Then I tap "Save" mark
    Then I should see the "Edit" screen
    And I should see the photo with the "sticker"
    
    Examples:
    | screen_name        |
    | Preview            |
    | Flickr Preview     |
    | CameraRoll Preview |
    
@reset
@TA14499
Scenario Outline: Verify Sticker delete option    
    Given I am on the "StickerEditor" screen for "<screen_name>"
    Then I select "sticker"
    And I should see the photo with the "sticker"
    Then I touch "Delete"
    Then I should see the "Edit" screen
    And I should see the photo with no "sticker"

     Examples:
    | screen_name        |
    | Preview            |
    | Flickr Preview     |
    | CameraRoll Preview |