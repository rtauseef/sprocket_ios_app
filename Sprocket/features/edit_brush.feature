Feature: Verify Brush option in Edit screen
  As a user
  I want to verify Brush option.

@TA18377
Scenario: Verify Brush screen
    Given I am on the "CameraRoll Preview " screen
    When I choose "edit" option
    Then I am on the "Edit" screen
    When I choose "brush" option
    Then I am on the "Brush Editor" screen
    And I could see "bring_to_front" option
    And I could see "hardness" option
    And I could see "size" option
    And I could see "color" option
    And I could see "delete" option
    And I could see "close" option
    And I could see "save" option
    
    
@done
@TA18377
Scenario: Verify Edit screen
    Given I am on the "BrushEditor" screen for "CameraRoll"
    And I choose "color" option
    And I select "Blue" color
    Then I choose "color_apply" option
    Then I choose "size" option
    And I set the value for "size_slider"
    #And I set the slider value to "30"
    And I verify the slider value
    Then I choose "hardness" option   
    And I set the value for "hardness_slider"
    And I verify the slider value
    Then I choose "save" option
    Then I should see the "Edit" screen
    And I choose "close" option
    Then I should see the "CameraRoll Preview" screen