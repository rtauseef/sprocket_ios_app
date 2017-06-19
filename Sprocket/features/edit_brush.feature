Feature: Verify Brush option in Edit screen
  As a user
  I want to verify Brush option.

@TA18377
Scenario: Verify Brush screen
    Given I am on the "CameraRoll Preview " screen
    When I tap "Edit" button
    Then I am on the "Edit" screen
    Then I tap "Brush" button
    Then I am on the "Brush Editor" screen
    And I could see "bring_to_front" option
    And I could see "hardness" option
    And I could see "size" option
    And I could see "color" option
    And I could see "delete" option
    And I could see "close" option
    And I could see "save" option
    
    
@done11
@TA18377
Scenario: Verify Edit screen
    Given I am on the "BrushEditor" screen for "CameraRoll"
    And I choose "color" option
    And I select "Blue" color
    Then I choose "color_apply" option
    Then I choose "size" option
    And I set the slider value to "30"
    And I verify the slider value is set to "30"
    Then I choose "hardness" option
    And I set the slider value to "0.5"
    And I verify the slider value is set to "0.5"
    Then I choose "save" option
    Then I should see the "Edit" screen
    When I tap "Close" mark
    Then I should see the "CameraRoll Preview" screen