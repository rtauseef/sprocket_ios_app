Feature: Verify Edit screen
  As a user
  I want to verify Edit features.

  
@reset
@TA14562
Scenario Outline: Verify 'Text' option
    Given I am on the "<screen_name>" screen
    When I tap "Edit" button
    Then I should see the "Edit" screen
    Then I tap "Text" button
    Then I should see the "TextEdit" screen
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
    | Preview            |
    | Flickr Preview     |
    | CameraRoll Preview |

@reset
@TA14562
Scenario Outline: Verify 'Text' option
    Given I am on the "TextEdit" screen for "CameraRoll" 
    And I enter unique text
    Then I tap "Cancel" mark
    Then I should see the "Edit" screen
   
   
    Examples:
    | screen_name        |
    | Preview            |
    | Flickr Preview     |
    | CameraRoll Preview |

@reset
@TA14562
Scenario Outline: Verify 'Text' option
    Given I am on the "TextEdit" screen for "CameraRoll" 
    And I enter unique text
    Then I tap "Add text" mark
    And I should see the photo with the "text"
    And I should not see the keyboard view
    And I should see "Bring to front" button
    And I should see "Delete" button
    And I should see "Font" button
    And I should see "Color" button
    And I should see "Backgoround color" button
    
       
    Examples:
    | screen_name        |
    | Preview            |
    | Flickr Preview     |
    | CameraRoll Preview |

    