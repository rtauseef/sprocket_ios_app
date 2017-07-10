Feature: Verify Brush option in Edit screen
  As a user
  I want to verify Brush option.

@TA18377
Scenario: Verify Brush screen
    Given I am on the "CameraRoll Preview" screen
    When I touch "Edit"
    Then I am on the "Edit" screen
    When I choose "brush" option
    Then I am on the "Brush Editor" screen
    And I should see "Bring to front" 
    And I should see "Hardness" 
    And I should see "Size" 
    And I should see "Color" 
    And I should see "Delete" 
    And I should see "Discard changes" 
    And I should see "Delete" 
    And I could see "save" option
    
    
@done
@TA18377
Scenario: Verify Edit screen
    Given I am on the "BrushEditor" screen for "CameraRoll"
    And I touch "Color"
    And I select "Blue" color
    Then I choose "color_apply" option
    Then I touch "Size"
    And I set the value for "size_slider"
    #And I set the slider value to "30"
    And I verify the slider value
    Then I touch "Hardness"   
    And I set the value for "hardness_slider"
    And I verify the slider value
    Then I choose "save" option
    Then I should see the "Edit" screen
    And I touch "Discard photo" 
    Then I should see the "CameraRoll Preview" screen