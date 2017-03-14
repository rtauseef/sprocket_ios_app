Feature: Verify Edit sticker feature
  As a user
  I want to verify sticker features.

@reset
@regression
Scenario: Verify 'Sticker' option
    Given I am on the "CameraRoll Preview" screen
    When I tap "Edit" button
    Then I should see the "Edit" screen
    Then I tap "Sticker" button
    Then I should see the "Sticker Editor" screen
    Then I select "sticker_0" sticker
    Then I should see the photo with the "sticker_0" sticker
    Then I tap "Close" mark
    Then I should see the "Edit" screen
    And I should see the photo with no "sticker"

    
@reset
@regression
Scenario Outline: Verify 'Sticker' option
    Given I am on the "StickerEditor" screen for "<social_media_screen_name>"
    Then I select "sticker_0" sticker
    Then I should see the photo with the "sticker_0" sticker
    Then I tap "Save" mark
    Then I should see the "Edit" screen
    Then I should see the photo with the "sticker_0" sticker
    
    Examples:
    | social_media_screen_name        |
    | Instagram Preview  |
  #  | Flickr Preview     |
    | CameraRoll Preview |
    
    
@reset
@TA17012
Scenario: Verify Sticker edit options
    Given I am on the "StickerEditor" screen for "CameraRoll Preview"
    Then I select "sticker_0" sticker
    Then I should see the photo with the "sticker_0" sticker
    And I should see "Bring to front" button
    And I should see "Delete" button
    And I should see "Flip vertically" button
    And I should see "Flip horizontally" button
    
    
@reset
@regression
Scenario Outline: Verify Sticker delete option    
    Given I am on the "StickerEditor" screen for "<social_media_screen_name>"
    Then I select "sticker_0" sticker
    Then I should see the photo with the "sticker_0" sticker
    Then I touch "Delete"
    Then I should see the "Edit" screen
    And I should see the photo with no "sticker"

     Examples:
    | social_media_screen_name        |
    | Instagram Preview  |
  #  | Flickr Preview     |
    | CameraRoll Preview |
    
    
@reset
@done
Scenario: Verify sticker list
    Given I am on the "StickerEditor" screen for "CameraRoll"
    Then I should see the following Stickers in the screen:
                | glasses_2b_TN         |
                | hat_1b_TN             |
                | kiss_me_2c_TN         |
                | derby_TN              |
                | st_hearts_TN          |
                | st_glasses_TN         |
                | boppers_TN            |
                | lips_TN               |
                | bow_tie_TN            |
                | beard&-eyebrows_TN    |
                | mustache_TN           |
                | pot_o_gold_TN         |
                | rainbow_2_TN          |
                | shamrock_crown_TN     |
                | shamrock_2_TN         |
                | #lucky_new_TN         |
                | shamrockin_3_TN       |
                | clover_headband_TN    |
                | clover_wand_TN        | 
                | hearts_TN             |
                | xoxo_TN               |
                | heartExpress_TN       | 
                | v_heart_TN            |
                | glasses_1_TN          |
                | heart_2_TN            |
                | v_hearts_TN           |
                | heart-garland_TN      |
                | v_xoxo_TN             |
                | heart_wings_TN        |  
                | palmtree_TN           |
                | beachball_TN          |
                | wave_TN               |
                | beach_umbrella_TN     |
                | sun_face_TN           |
                | sunglasses_frogskin_TN|
                | aviator_glasses_TN    |
                | glasses_TN            |
                | bunny_ears_flowers_TN |
                | catglasses_TN         |
                | catears_TN            |
                | scuba_mask_TN         |
                | swim_fins_TN          |
                | volleyball_TN         |
                | trailer_TN            | 
                | travel_car_bug_TN     |
                | travel_car_woody_TN   |
                | bike_cruiser_TN       |
                | airplane_TN           |
                | soda_straw_TN         |
                | sundae_TN             |
                | icecream_tub_TN       |
                | cupcake_TN            |
                | bbq_TN                |
                | unicorn_float_TN      |
                | surfboard_TN          |
                | crown_TN              |
                | birthdayHat_TN        |
                | diamond_TN            |
                | feather_TN            |
                | stars_TN              |
                | starhp_TN             |
                | cat_TN                |
                | smiley_TN             |
                
                
@reset
@regression
Scenario: Verify all the stickers are applied for sticker editor screen 
    Given I am on the "StickerEditor" screen for "CameraRoll"  
    Then I verify that all the "stickers" are applied successfully
    
@reset
@TA17012
Scenario Outline: Verify sticker editor screen navigation
    Given I am on the "StickerEditor" screen for "<social_media_screen_name>"
    Then I select "sticker_1" sticker
    And I should see the photo with the "sticker_1" sticker
    Then I should see the "StickerEditor" screen
    Then I tap "Close" mark
    Then I should see the "Edit" screen
    Then I tap "Sticker" button
    Then I select "sticker_4" sticker
    And I should see the photo with the "sticker_4" sticker
    Then I tap "Save" mark
    Then I should see the "Edit" screen
    
    Examples:
    | social_media_screen_name       |
    | Instagram Preview  |
    #| Flickr Preview     |
    | CameraRoll         |    
    