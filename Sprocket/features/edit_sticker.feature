Feature: Verify Edit sticker feature
  As a user
  I want to verify sticker features.

@reset
@regression
Scenario Outline: Verify 'Sticker' option
    Given I am on the "<social_media_screen_name>" screen
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
    | social_media_screen_name        |
    | Instagram Preview  |
    | Flickr Preview     |
    | CameraRoll Preview |
    
@reset
@regression
Scenario Outline: Verify 'Sticker' option
    Given I am on the "StickerEditor" screen for "<social_media_screen_name>"
    Then I select "sticker"
    And I should see the photo with the "sticker"
    Then I tap "Save" mark
    Then I should see the "Edit" screen
    And I should see the photo with the "sticker"
    
    Examples:
    | social_media_screen_name        |
    | Instagram Preview  |
    | Flickr Preview     |
    | CameraRoll Preview |
    
@reset
@regression
Scenario Outline: Verify Sticker delete option    
    Given I am on the "StickerEditor" screen for "<social_media_screen_name>"
    Then I select "sticker"
    And I should see the photo with the "sticker"
    Then I touch "Delete"
    Then I should see the "Edit" screen
    And I should see the photo with no "sticker"

     Examples:
    | social_media_screen_name        |
    | Instagram Preview  |
    | Flickr Preview     |
    | CameraRoll Preview |
    
    
@reset
@done
Scenario: Verify sticker list
    Given I am on the "StickerEditor" screen for "CameraRoll"
    Then I should see the following Stickers in the screen:
                | v_xoxo_TN             |
                | heart_2_TN            |
                | v_hearts_TN           |
                | conversation_heart_TN |
                | heart_wings_TN        |
                | bird_TN               |
                | butterfly_TN          |
                | monster_2_TN          |
                | rosebud_TN            |
                | heart_bouquet_TN      |
                | heart-garland_TN      |
                | pig_TN                |
                | headband_TN           |
                | glasses_1_TN          |
                | hat_TN                |
                | bow2_TN               |
                | balloons_TN           |
                | thought_bubble_TN     |
                | letter_TN             | 
                | holding_hands_TN      |
                | love_monster_TN       |
                | heart_arrow_TN        | 
                | smiley_TN             |
                | heart_banner_TN       |
                | lock_TN               |
                | v_cupcake_TN          |
                | v_cat_TN              |
                | v_heart_TN            |
                | target_TN             |  
                | glasses_TN            |
                | tiara_TN              |
                | heart_crown_TN        |
                | sb_glasses_TN         |
                | glasses_2_TN          |
                | eye_black_TN          |
                | foam_finger_TN        |
                | heart_football3_TN    |
                | banner_TN             |
                | flag_TN               |
                | heart_football_TN     |
                | stars_n_balls_TN      |
                | #_game_time_TN        |
                | football_flames_TN    | 
                | love_TN               |
                | i_heart_football_2_TN |
                | owl_TN                |
                | goal_post_2_TN        |
                | helmet_TN             |
                | catglasses_TN         |
                | catwhiskers_TN        |
                | catears_TN            |
                | hearts_TN             |
                | xoxo_TN               |
                | heartExpress_TN       |
                | arrow_TN              |
                | crown_TN              |
                | birthdayHat_TN        |
                | moon_TN               |
                | starhp_TN             |
                | stars_TN              |
                | feather2_TN           |
                | feather_TN            |
                | leaf3_TN              |
                | cupcake_TN            |
                | cat_TN                |
                | diamond_TN            |
                | sunglasses_TN         |
                | OMG_TN                |
                
@reset
@done
Scenario: Verify all the stickers are applied for sticker editor screen 
    Given I am on the "StickerEditor" screen for "CameraRoll"  
    Then I verify that all the "stickers" are applied successfully
    