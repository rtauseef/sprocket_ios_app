Feature: Verify Edit crop feature
  As a user
  I want to verify crop features.

@regression
Scenario Outline: Verify crop option
    Given I am on the "<social_media_screen_name>" screen
    When I touch "Edit"
    Then I am on the "Edit" screen
    Then I choose "crop" option
    Then I should see the "Crop Editor" screen
    And I should see "2:3" 
    And I should see "3:2"
    And I select "2:3"
    Then I touch "Discard changes"
    Then I should see the "Edit" screen
    And I should see the "uncropped" image
          
    Examples:
    | social_media_screen_name  |
    | Instagram Preview         |
    | CameraRoll Preview        |
    
 
@regression
@done
Scenario: Verify image crop
    Given I am on the "CameraRoll Preview" screen
    When I touch "Edit"
    Then I am on the "Edit" screen
    Then I choose "crop" option
    Then I should see the "Crop Editor" screen
    And I select "3:2"
    Then I choose "save" option
    Then I should see the "Edit" screen
    And I should see the "cropped" image



    #2:3 crop not reflected on verification
@block
Scenario Outline: Verify image crop for both options
    Given I am on the "CameraRoll Preview" screen
    When I touch "Edit"
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
    
    
    
    