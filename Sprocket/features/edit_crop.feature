Feature: Verify Edit crop feature
  As a user
  I want to verify crop features.

@regression
Scenario Outline: Verify crop option
    Given I am on the "<social_media_screen_name>" screen
    When I choose "edit" option
    Then I am on the "Edit" screen
    Then I choose "crop" option
    Then I should see the "Crop Editor" screen
    And I could see "2:3" option
    And I could see "3:2" option
    And I select "2:3"
    Then I choose "close" option
    Then I should see the "Edit" screen
    And I should see the "uncropped" image
          
    Examples:
    | social_media_screen_name|
    | Instagram Preview  |
    | CameraRoll Preview |
    
 
@regression
Scenario Outline: Verify image crop
    Given I am on the "<social_media_screen_name>" screen
    When I choose "edit" option
    Then I am on the "Edit" screen
    Then I choose "crop" option
    Then I should see the "Crop Editor" screen
    And I select "3:2"
    Then I choose "save" option
    Then I should see the "Edit" screen
    And I should see the "cropped" image
       
    Examples:
    | social_media_screen_name|
    | Instagram Preview  |
    | CameraRoll Preview |
    

@done
Scenario Outline: Verify image crop for both options
    Given I am on the "CameraRoll Preview" screen
    When I choose "edit" option
    Then I am on the "Edit" screen
    Then I choose "crop" option
    Then I should see the "Crop Editor" screen
    And I select "<crop_option>"
    Then I choose "save" option
    Then I should see the "Edit" screen
    And I should see the "cropped" image
    
    Examples:
    | crop_option |
    | 2:3         |
    | 3:2         |
    
    
    
    