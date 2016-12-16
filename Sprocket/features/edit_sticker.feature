Feature: Verify Edit sticker feature
  As a user
  I want to verify sticker features.

@reset
@regression
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
    | Instagram Preview  |
    | Flickr Preview     |
    | CameraRoll Preview |
    
@reset
@done
Scenario Outline: Verify 'Sticker' option
    Given I am on the "StickerEditor" screen for "<screen_name>"
    Then I select "sticker"
    And I should see the photo with the "sticker"
    Then I tap "Save" mark
    Then I should see the "Edit" screen
    And I should see the photo with the "sticker"
    
    Examples:
    | screen_name        |
    | Instagram Preview  |
    | Flickr Preview     |
    | CameraRoll Preview |
    
@reset
@done
Scenario Outline: Verify Sticker delete option    
    Given I am on the "StickerEditor" screen for "<screen_name>"
    Then I select "sticker"
    And I should see the photo with the "sticker"
    Then I touch "Delete"
    Then I should see the "Edit" screen
    And I should see the photo with no "sticker"

     Examples:
    | screen_name        |
    | Instagram Preview  |
    | Flickr Preview     |
    | CameraRoll Preview |
    
    
@reset
@TA16210
Scenario: Verify sticker list
    Given I am on the "StickerEditor" screen for "CameraRoll"
    Then I should see the following Stickers in the screen:
                | snowman_TN         |
                | glasses_rudolph_TN |
                | christmas_hat_TN   |
                | star0_TN           |
                | glasses_hanukah_TN |
                | snowman_hat_TN     |
                | Party-Hat_TN       |
                | glasses_tree_TN    |
                | glasses_star_TN    |
                | rudolph_antlers_TN |
                | cap_TN             |
                | snowman_face_TN    |
                | scarf_TN           |
                | snowflake_2_TN     |
                | StringOLights_TN   |
                | tree_TN            |
                | stocking_TN        |
                | candy_cane_TN      |
                | holly_TN           | 
                | mistletoe_TN       |
                | ornament_1_TN      |
                | menorah_TN         | 
                | dreidle_TN         |
                | fireworks_TN       |
                | horn_TN            |
                | catglasses_TN      |
                | catwhiskers_TN     |
                | catears_TN         |
                | hearts_TN          |
                | xoxo_TN            |
                | heartExpress_TN    |
                | arrow_TN           |
                | crown_TN           |
                | birthdayHat_TN     |
                | moon_TN            |
                | starhp_TN          |
                | stars_TN           |
                | feather2_TN        |
                | feather_TN         |
                | leaf3_TN           |
                | cupcake_TN         |
                | cat_TN             |
                | diamond_TN         |
                | sunglasses_TN      | 
                | OMG_TN             |
                
@reset
@TA16210
Scenario: Verify all the stickers are applied for sticker editor screen 
    Given I am on the "StickerEditor" screen for "CameraRoll"  
    Then I verify that all the "stickers" are applied successfully
    