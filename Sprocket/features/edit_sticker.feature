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
    And I select "Summer Category" tab
    Then I select "sticker_0" sticker
    Then I should see the "StickerOptionEditor" screen
    Then I should see the photo with the "sticker_0" sticker
    Then I tap "Close" mark
    Then I should see the "Edit" screen
    And I should see the photo with the "sticker_0" sticker

@regression
Scenario Outline: Verify 'Sticker' option
    Given I am on the "StickerEditor" screen for "<social_media_screen_name>"
    And I select "Graduation Category" tab
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
    And I select "Graduation Category" tab
    Then I select "sticker_21" sticker
    Then I am on the "StickerOptionEditor" screen
    And I should see the photo with the "sticker_21" sticker
    And I should see "Add" button
    And I should see "Delete" button
    And I should see "Color" button
    And I should see "Flip" button
    And I should see "Bring to front" button
    And I should see "Undo" mark
    And I should see "Redo" mark
    #And I should see "Flip horizontally" button
    
    
@regression
@done
Scenario Outline: Verify Sticker delete option    
    Given I am on the "StickerEditor" screen for "<social_media_screen_name>"
    And I select "Graduation Category" tab
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
Scenario Outline: Verify sticker list
    Given I am on the "StickerEditor" screen for "CameraRoll"
    And I select "<sticker_tab_name>" tab
    Then I should see the all the corresponding "stickers"
    Examples:
    | sticker_tab_name   |
    | Graduation Category|
    | Summer Category    |
    | Cannes Category    |
    | Face Category      |
    | Decorative Category|
    | Food Category      |
    | Birthday Category  |
    | Animal Category    |
    | Nature Category    |
    | Get Well           |
                    
                              
@regression
Scenario Outline: Verify all the stickers are applied for sticker editor screen 
    Given I am on the "StickerEditor" screen for "CameraRoll"  
    And I select "<sticker_tab_name>" tab
    Then I verify that all the "stickers" are applied successfully
    Examples:
    | sticker_tab_name   |
    | Graduation Category|
    | Summer Category    |
    | Cannes Category    |
    | Face Category      |
    | Decorative Category|
    | Food Category      |
    | Birthday Category  |
    | Animal Category    |
    | Nature Category    |
    | Get Well           |


    

@done
Scenario Outline: Verify sticker editor screen navigation
    Given I am on the "StickerEditor" screen for "<social_media_screen_name>"
    And I select "Graduation Category" tab
    Then I select "sticker_1" sticker
    Then I should see the "StickerOptionEditor" screen
    And I should see the photo with the "sticker_1" sticker
    Then I touch "Delete"
    Then I should see the "Edit" screen
    Then I tap "Sticker" button
    And I select "Graduation Category" tab
    Then I select "sticker_4" sticker
    Then I am on the "StickerOptionEditor" screen
    And I should see the photo with the "sticker_4" sticker
    Then I tap "Save" mark
    Then I should see the "Edit" screen
    
    Examples:
    | social_media_screen_name       |
    | Instagram Preview  |
    | CameraRoll         |  

@done
Scenario: Verify Sticker edit options
    Given I am on the "StickerEditor" screen for "CameraRoll Preview"
    And I select "Graduation Category" tab
    Then I select "sticker_3" sticker
    Then I am on the "StickerOptionEditor" screen
    And I should see the photo with the "sticker_3" sticker
    Then I touch "Add"  
    Then I should see the "Sticker Editor" screen
    And I select "Summer Category" tab
    Then I select "sticker_3" sticker
    Then I should see the "StickerOptionEditor" screen

@done
Scenario: Verify Sticker edit options
    Given I am on the "StickerEditor" screen for "CameraRoll Preview"
    And I select "Graduation Category" tab
    Then I select "sticker_21" sticker
    Then I am on the "StickerOptionEditor" screen
    Then I touch "Color"  
    Then I should see the following "Colors" in the screen:
    | Transparent|
    | White      |
    | Gray       |
    | Black      |
    | Light blue |
    | Blue       |
    | Purple     |
    | Orchid     |
    | Pink       |
    | Red        |
    | Orange     |
    | Gold       |
    | Yellow     |
    | Olive      |
    | Green      |
    | Aquamarin  |
    
@done
Scenario: Verify Sticker edit options
    Given I am on the "StickerEditor" screen for "CameraRoll Preview"
    And I select "Graduation Category" tab
    Then I select "sticker_21" sticker
    Then I am on the "StickerOptionEditor" screen
    Then I touch "Color"  
    And I select "Olive" color
    Then I should see the "sticker" with "Olive" Color