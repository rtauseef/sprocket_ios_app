Feature: Verify Edit sticker feature
  As a user
  I want to verify sticker features.

@done
Scenario: Verify 'Sticker' option
    Given I am on the "CameraRoll Preview" screen
    When I tap "Edit" button
    Then I should see the "Edit" screen
    Then I tap "Sticker" button
    Then I should see the "Sticker Editor" screen
    Then I select "sticker_0" sticker
    Then I should see the "StickerOptionEditor" screen
    Then I should see the photo with the "sticker_0" sticker
    Then I tap "Close" mark
    Then I should see the "Edit" screen
    And I should see the photo with the "sticker_0" sticker

@regression
Scenario Outline: Verify 'Sticker' option
    Given I am on the "StickerEditor" screen for "<social_media_screen_name>"
    Then I select "sticker_0" sticker
    Then I am on the "StickerOptionEditor" screen
    Then I tap "Save" mark
    Then I am on the "Edit" screen
    Then I should see the photo with the "sticker_0" sticker
       
    Examples:
    | social_media_screen_name        |
    | Instagram Preview  |
    | CameraRoll Preview |
    
    
@regression
Scenario: Verify Sticker edit options
    Given I am on the "StickerEditor" screen for "CameraRoll Preview"
    Then I select "sticker_0" sticker
    Then I am on the "StickerOptionEditor" screen
    And I should see the photo with the "sticker_0" sticker
    And I should see "Add" button
    And I should see "Delete" button
    And I should see "Color" button
    And I should see "Flip" button
    And I should see "Bring to front" button
    #And I should see "Flip horizontally" button
    
    
@regression
@done
Scenario Outline: Verify Sticker delete option    
    Given I am on the "StickerEditor" screen for "<social_media_screen_name>"
    Then I select "sticker_0" sticker
    Then I should see the "StickerOptionEditor" screen
    Then I should see the photo with the "sticker_0" sticker
    Then I touch "Delete"
    Then I should see the "Edit" screen
    And I should see the photo with no "sticker"

     Examples:
    | social_media_screen_name        |
    | Instagram Preview  |
    | CameraRoll Preview |
    
    
@done
Scenario: Verify sticker list
    Given I am on the "StickerEditor" screen for "CameraRoll"
    Then I should see the following Stickers in the screen:
                | Hearts Doodle Sticker       |
                | Heart 2 Sticker             |
                | Palm Tree Sticker           |
                | Sunglasses Frogskin Sticker |
                | Cat Ears Sticker            |
                | Travel Car Sticker          |
                | Sundae Sticker              |
                | Xoxo Sticker                |
                | Hearts Sticker              |
                | Beach Ball Sticker          |
                | Aviator Glasses Sticker     |
                | Scuba Mask Sticker          |
                | Travel Car Woody Sticker    |
                | Ice Cream Tub Sticker       |
                | Heart Express Sticker       |
                | Heart Garland Sticker       |
                | Wave Sticker                |
                | Glasses Sticker             |
                | Swim Fins Sticker           |
                | Bike Cruiser Sticker        |
                | Cupcake Sticker             |
                | Heart Sticker               |
                | Valentines Xoxo Sticker     |
                | Beach Umbrella Sticker      |
                | Bunny Ears Flowers Sticker  |
                | Volley Ball Sticker         |
                | Airplane Sticker            |
                | BBQ Sticker                 |
                | Glasses 1 Sticker           |
                | Heart Wings Sticker         |
                | Sun Face Sticker            | 
                | Cat Glasses Sticker         |
                | Trailer Sticker             |
                | Soda Straw Sticker          | 
                | Unicorn Float Sticker       |
                | Surf Board Sticker          |
                | Crown Sticker               |
                | Stars Sticker               |
                |Smiley Sticker               |
                |Birthday Hat Sticker         |
                |Star Sticker                 |
                |Cat Face Sticker             |
                |Feather Sticker              |
                |Diamond Sticker              |
                

@regression
Scenario: Verify all the stickers are applied for sticker editor screen 
    Given I am on the "StickerEditor" screen for "CameraRoll"  
    Then I verify that all the "stickers" are applied successfully
    

@done
Scenario Outline: Verify sticker editor screen navigation
    Given I am on the "StickerEditor" screen for "<social_media_screen_name>"
    Then I select "sticker_1" sticker
    Then I should see the "StickerOptionEditor" screen
    And I should see the photo with the "sticker_1" sticker
    Then I touch "Delete"
    Then I should see the "Edit" screen
    Then I tap "Sticker" button
    Then I select "sticker_4" sticker
    Then I am on the "StickerOptionEditor" screen
    And I should see the photo with the "sticker_4" sticker
    Then I tap "Save" mark
    Then I should see the "Edit" screen
    
    Examples:
    | social_media_screen_name       |
    | Instagram Preview  |
    | CameraRoll         |    
    