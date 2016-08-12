Feature: Verify Edit screen
  As a user
  I want to verify Edit features.

@reset
@TA14417
Scenario Outline: Verify Edit screen
    Given I am on the "<screen_name>" screen
    When I tap "Edit" button
    Then I should see the "Edit" screen
    Then I should see "Filter" option
    Then I should see "Frame" option
    Then I should see "Sticker" option
    Then I should see "Text" option
    Then I should see "Crop" option
    Then I should see "Close" mark
    Then I should see "Check" mark
    
    Examples:
    | screen_name            |
    | Preview            |
    | Flickr Preview     |
    | CameraRoll Preview |
    
    
@reset
@TA14417
Scenario Outline: Verify close button for edit screen
    Given I am on the "<screen_name>" screen
    When I tap "Edit" button
    Then I should see the "Edit" screen
    When I tap "Close" mark
    #Then I should see the modal screen title
    #Then I should see the modal screen content
    #Then I tap "No" button
    #Then I should see the "Edit" screen
    #Then I tap "Close" mark
    #Then I should see the modal screen title
    #Then I should see the modal screen content
    #Then I tap "Yes" button
    Then I should see the "Preview" screen
    
    Examples:
    | screen_name            |
    | Preview            |
    | Flickr Preview     |
    | CameraRoll Preview |
    
    

    
 