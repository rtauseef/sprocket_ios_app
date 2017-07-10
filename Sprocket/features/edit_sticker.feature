Feature: Verify Edit sticker feature
  As a user
  I want to verify sticker features.

@done
Scenario: Verify 'Sticker' selection in sticker option editor screen
    Given I am on the "CameraRoll Preview" screen
    When I choose "edit" option
    Then I should see the "Edit" screen
    Then I choose "sticker" option
    Then I should see the "Sticker Editor" screen
    And I select "Summer Category" tab
    Then I select "sticker_0" sticker
    Then I should see the "StickerOptionEditor" screen
    And I should see the photo with the "sticker_0" sticker from "Summer Category" tab
    Then I choose "close" option
    Then I should see the "Edit" screen
    And I should see the photo with the "sticker_0" sticker from "Summer Category" tab

@regression
Scenario Outline: Verify 'Sticker' selection in edit screen
    Given I am on the "StickerEditor" screen for "<social_media_screen_name>"
    And I select "Face Category" tab
    Then I select "sticker_0" sticker
    Then I am on the "StickerOptionEditor" screen
    Then I choose "save" option
    Then I am on the "Edit" screen
    And I should see the photo with the "sticker_0" sticker from "Face Category" tab
       
    Examples:
    | social_media_screen_name        |
    | Instagram Preview  |
    | CameraRoll Preview |
    
    
@regression
Scenario: Verify Sticker edit options
    Given I am on the "StickerEditor" screen for "CameraRoll Preview"
    And I select "Decorative Category" tab
    Then I select "sticker_21" sticker
    Then I am on the "StickerOptionEditor" screen
    And I should see the photo with the "sticker_21" sticker from "Decorative Category" tab
    And I could see "Add" option
    And I could see "Delete" option
    And I could see "Color" option
    And I could see "Flip" option
    And I could see "Bring to front" option
    
    
@regression
@done
Scenario Outline: Verify Sticker delete option    
    Given I am on the "StickerEditor" screen for "<social_media_screen_name>"
    And I select "Face Category" tab
    Then I select "sticker_0" sticker
    Then I should see the "StickerOptionEditor" screen
    And I should see the photo with the "sticker_0" sticker from "Face Category" tab
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
    | sticker_tab_name        |
    | Summer Category         |
    | Fathers Day Category    |    
    | Face Category           |
    | Decorative Category     |    
    | Food Category           |
    | Birthday Category       |
    | Animal Category         |
    | Nature Category         |
    | Get Well                |
    | Disney                  |
                    
                              
@regression
Scenario Outline: Verify all the stickers are applied for sticker editor screen 
    Given I am on the "StickerEditor" screen for "CameraRoll"  
    And I select "<sticker_tab_name>" tab
    Then I verify that all the "stickers" are applied successfully
    Examples:
    | sticker_tab_name      |
    | Summer Category       |
    | Fathers Day Category  |
    | Face Category         |
    | Decorative Category   |
    | Food Category         |
    | Birthday Category     |
    | Animal Category       |
    | Nature Category       |
    | Get Well              |
    | Disney                |

    

@done
Scenario Outline: Verify sticker editor screen navigation
    Given I am on the "StickerEditor" screen for "<social_media_screen_name>"
    And I select "Animal Category" tab
    Then I select "sticker_1" sticker
    Then I should see the "StickerOptionEditor" screen
    And I should see the photo with the "sticker_1" sticker from "Animal Category" tab
    Then I touch "Delete"
    Then I should see the "Edit" screen
    Then I choose "sticker" option
    And I select "Animal Category" tab
    Then I select "sticker_4" sticker
    Then I am on the "StickerOptionEditor" screen
    And I should see the photo with the "sticker_4" sticker from "Animal Category" tab
    Then I choose "save" option
    Then I should see the "Edit" screen
    
    Examples:
    | social_media_screen_name|
    | Instagram Preview       |
    | CameraRoll              |  

@done
@TA17968
Scenario: Verify Sticker add option
    Given I am on the "StickerEditor" screen for "CameraRoll Preview"
    And I select "Face Category" tab
    Then I select "sticker_3" sticker
    Then I am on the "StickerOptionEditor" screen
    And I should see the photo with the "sticker_3" sticker from "Face Category" tab
    Then I touch "Add"  
    Then I should see the "Sticker Editor" screen
    And I select "Decorative Category" tab
    Then I select "sticker_7" sticker
    Then I should see the "StickerOptionEditor" screen
    And I should see the photo with the "sticker_7" sticker from "Decorative Category" tab
    Then I choose "save" option
    Then I should see the "Edit" screen
    And I should see the photo with the "sticker_7" sticker from "Decorative Category" tab

@done
Scenario: Verify Sticker color options
    Given I am on the "StickerEditor" screen for "CameraRoll Preview"
    And I select "Decorative Category" tab
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
@TA17968
Scenario: Verify Sticker color selection
    Given I am on the "StickerEditor" screen for "CameraRoll Preview"
    And I select "Decorative Category" tab
    Then I select "sticker_21" sticker
    Then I am on the "StickerOptionEditor" screen
    Then I touch "Color"  
    Then I verify that all the "colors" are applied successfully
    

@TA17968
Scenario: Verify Sticker add/delete functionality
    Given I am on the "StickerEditor" screen for "CameraRoll Preview"
    And I select "Decorative Category" tab
    Then I select "sticker_3" sticker
    Then I touch "Add"  
    And I select "Summer Category" tab
    Then I select "sticker_7" sticker
    Then I touch "Add"  
    And I select "Decorative Category" tab
    Then I select "sticker_0" sticker
    Then I touch "Delete"
    Then I should see the "Edit" screen
    Then I choose "sticker" option
    And I select "Face Category" tab
    Then I select "sticker_11" sticker
    #Then I should see the "StickerOptionEditor" screen
    Then I touch "Add"  
    And I select "Decorative Category" tab
    Then I select "sticker_9" sticker
    Then I touch "Delete"
    Then I should see the "Edit" screen
    And I should see the photo with the "sticker_3" sticker from "Decorative Category" tab
    And I should see the photo with the "sticker_7" sticker from "Summer Category" tab
    And I should see the photo with the "sticker_11" sticker from "Face Category" tab

