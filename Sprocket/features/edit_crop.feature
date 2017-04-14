Feature: Verify Edit crop feature
  As a user
  I want to verify crop features.

@reset
@regression
Scenario Outline: Verify crop option
    Given I am on the "<social_media_screen_name>" screen
    When I tap "Edit" button
    Then I am on the "Edit" screen
    Then I tap "Crop" button
    Then I should see the "Crop Editor" screen
    And I should see "2:3" button
    And I should see "3:2" button
    And I select "2:3"
    Then I tap "Close" mark
    Then I should see the "Edit" screen
    And I should see the "uncropped" image
          
    Examples:
    | social_media_screen_name|
    | Instagram Preview  |
   # | Flickr Preview     |
    | CameraRoll Preview |
    
 
@reset
@regression
Scenario Outline: Verify image crop
    Given I am on the "<social_media_screen_name>" screen
    When I tap "Edit" button
    Then I am on the "Edit" screen
    Then I tap "Crop" button
    Then I should see the "Crop Editor" screen
    And I select "3:2"
    Then I tap "Save" mark
    Then I should see the "Edit" screen
    And I should see the "cropped" image
       
    Examples:
    | social_media_screen_name|
    | Instagram Preview  |
 #   | Flickr Preview     |
    | CameraRoll Preview |
    

@reset
@done
Scenario Outline: Verify image crop for both options
    Given I am on the "CameraRoll Preview" screen
    When I tap "Edit" button
    Then I am on the "Edit" screen
    Then I tap "Crop" button
    Then I should see the "Crop Editor" screen
    And I select "<crop_option>"
    Then I tap "Save" mark
    Then I should see the "Edit" screen
    And I should see the "cropped" image
    
    Examples:
    | crop_option |
    | 2:3         |
    | 3:2         |
    
    
    
    