Feature: Verify Edit screen
  As a user
  I want to verify Edit features.

  
@reset
@TA14417
@test11
Scenario Outline: Verify 'Text' option
    Given I am on the "<screen_name>" screen
    When I tap "Edit" button
    Then I should see the "Edit" screen
    Then I tap "Text" button
    And I enter unique text
    Then I tap "Add text" mark
    And I tap "Save" mark
    Then I should see the "Edit" screen
    And I should see the photo with the "text"
    #And I should see the photo with the entered text
    Then I tap "Check" mark
    Then I should see the "Preview" screen
   
    Examples:
    | screen_name        |
    #| Preview            |
    #| Flickr Preview     |
    | CameraRoll Preview |