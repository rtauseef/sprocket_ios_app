Feature: Verify Text Edit screen
  As a user
  I want to verify Edit text features.

  
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
Scenario Outline: Verify text edit screen navigation
    Given I am on the "TextEdit" screen for "<screen_name>" 
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
Scenario Outline: Verify Text editor screen options
    Given I am on the "TextEdit" screen for "<screen_name>" 
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

@reset
@TA14562
@DE4168
Scenario: Verify entered text cancellation
    Given I am on the "TextEdit" screen for "CameraRoll Preview" 
    And I enter unique text
    Then I tap "Add text" mark
    And I should see the photo with the "text"
    Then I tap "Close" mark
    Then I should see the "Edit" screen
    And I should not see the text

@reset
@TA14562
Scenario: Verify font
    Given I am on the "TextEdit" screen for "CameraRoll Preview" 
    And I enter unique text
    Then I tap "Add text" mark
    And I should see the photo with the "text"
    Then I select "Font" 
    And I select "Avenir"
    Then I tap "Save" mark
    Then I wait for some seconds
    Then I should see the text with selected "Font"

@reset
@TA14562
Scenario: Verify text color
    Given I am on the "TextEdit" screen for "CameraRoll Preview" 
    And I enter unique text
    Then I tap "Add text" mark
    And I should see the photo with the "text"
    Then I select "Color" 
    And I select "Blue"
    Then I wait for some seconds
    Then I tap "Save" mark
    Then I wait for some seconds
    Then I should see the text with selected "Color"

@reset
@TA14562
@test11
Scenario: Verify text background
    Given I am on the "TextEdit" screen for "CameraRoll Preview" 
    And I enter unique text
    Then I tap "Add text" mark
    And I should see the photo with the "text"
    Then I select "Backgoround color" 
    And I select "Gray"
    Then I wait for some seconds
    Then I tap "Save" mark
    Then I wait for some seconds
    Then I should see the text with selected "Background Color"
    