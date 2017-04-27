Feature: Verify Text Edit screen
  As a user
  I want to verify Edit text features.

@done
Scenario Outline: Verify 'Text' option
    Given I am on the "<social_media_screen_name>" screen
    When I tap "Edit" button
    Then I should see the "Edit" screen
    Then I tap "Text" button
    Then I should see the "TextEdit" screen
    And I enter unique text
    Then I tap "Add text" mark
    Then I should see the "TextOptionEditor" screen
    And I tap "Save" mark
    Then I should see the "Edit" screen
    And I should see the photo with the "text"
    Then I tap "Check" mark
    Then I should see the "<social_media_screen_name>" screen
   
    Examples:
    | social_media_screen_name        |
    | Instagram Preview  |
    | CameraRoll Preview |

@done
Scenario: Verify text edit screen navigation
    Given I am on the "TextEdit" screen for "CameraRoll Preview"
    And I enter unique text
    Then I tap "Cancel" mark
    Then I should see the "Edit" screen

@regression
Scenario Outline: Verify Text editor screen options
    Given I am on the "TextEdit" screen for "<social_media_screen_name>" 
    And I enter unique text
    Then I tap "Add text" mark
    And I should see the photo with the "text"
    And I should not see the keyboard view
    And I should see "Bring to front" button
    And I should see "Delete" button
    And I should see "Font" button
    And I should see "Color" button
    And I should see "Background color" button
    
       
    Examples:
    | social_media_screen_name        |
    | Instagram Preview  |
    | Flickr Preview     |
    | CameraRoll Preview |


@DE4168
Scenario: Verify entered text cancellation
    Given I am on the "TextEdit" screen for "CameraRoll Preview" 
    And I enter unique text
    Then I tap "Add text" mark
    Then I should see the "TextOptionEditor" screen
    And I should see the photo with the "text"
    Then I tap "Close" mark
    Then I should see the "Edit" screen
    And I should see the photo with the "text"
    

@regression
Scenario: Verify text deletion option
    Given I am on the "TextEdit" screen for "CameraRoll Preview" 
    And I enter unique text
    Then I tap "Add text" mark
    Then I should see the "TextOptionEditor" screen
    And I should see the photo with the "text"
    Then I touch "Delete"
    And I should not see the text


@done
Scenario: Verify font
    Given I am on the "TextEdit" screen for "CameraRoll Preview" 
    And I enter unique text
    Then I tap "Add text" mark
    Then I should see the "TextOptionEditor" screen
    And I should see the photo with the "text"
    Then I select "Font" 
    #And I select "Avenir"
    And I select "font_2" font
    Then I tap "Save" mark
    Then I wait for some seconds
    #Then I should see the text with selected "Font"
    Then I should see the photo with the "font_2" font
    
  
@regression
Scenario: Verify font list
    Given I am on the "TextEdit" screen for "CameraRoll Preview"
    And I enter unique text
    Then I tap "Add text" mark
    And I should see the photo with the "text"
    Then I select "Font"
    Then I should see the following "Fonts" in the screen:
    
    | Aleo                | 
    | BERNIER Regular     |
    | Blogger Sans        |
    | Cheque              |
    | Fira Sans           |
    | Gagalin             |
    | Hagin Caps Thin     |
    | Panton              |
    | Panton              |
    | Perfograma          |
    | Summer Font         |
    | American Typewriter |
    | Baskerville         |
    | Bodoni 72           |
    | Bradley Hand        |
    | Chalkboard SE       |
    | DIN Alternate       |
    | Helvetica Neue      |
    | Noteworthy          |
    | Snell Roundhand     |
    | Thonburi            |
    
    
@regression
Scenario: Verify all the fonts are applied successfully
    Given I am on the "TextEdit" screen for "CameraRoll Preview"
    And I enter unique text
    Then I tap "Add text" mark
    And I should see the photo with the "text"
    Then I select "Font"
    Then I verify that all the "fonts" are applied successfully

@done
Scenario: Verify text color
    Given I am on the "TextEdit" screen for "CameraRoll Preview" 
    And I enter unique text
    Then I tap "Add text" mark
    Then I should see the "TextOptionEditor" screen
    And I should see the photo with the "text"
    Then I select "Color" 
    And I select "Blue"
    Then I wait for some seconds
    Then I tap "Save" mark
    Then I wait for some seconds
    Then I should see the text with selected "Color"
      
@regression
Scenario: Verify color list
    Given I am on the "TextEdit" screen for "CameraRoll Preview" 
    And I enter unique text
    Then I tap "Add text" mark
    Then I should see the "TextOptionEditor" screen
    And I should see the photo with the "text"
    Then I select "Color" 
    Then I should see the following "Colors" in the screen:
    | White      |
    | Gray       |
    | Black      |
    | Light blue |
    | Blue       |
    | Purple     |
    | Orchid     |
    | Pink       |
    | Red        |
    | Orange     |
    | Gold       |
    | Yellow     |
    | Olive      |
    | Green      |
    | Aquamarin  |
  
@TA17012
Scenario: Verify all the colors are applied successfully
    Given I am on the "TextEdit" screen for "CameraRoll Preview" 
    And I enter unique text
    Then I tap "Add text" mark
    Then I should see the "TextOptionEditor" screen
    And I should see the photo with the "text"
    Then I select "Color"
    Then I verify that all the "colors" are applied successfully

@done
Scenario: Verify text background
    Given I am on the "TextEdit" screen for "CameraRoll Preview" 
    And I enter unique text
    Then I tap "Add text" mark
    And I should see the photo with the "text"
    Then I select "Background color" 
    And I select "Gray"
    Then I wait for some seconds
    Then I tap "Save" mark
    Then I wait for some seconds
    Then I should see the text with selected "Background Color"
      
@regression
Scenario: Verify background color list
    Given I am on the "TextEdit" screen for "CameraRoll Preview" 
    And I enter unique text
    Then I tap "Add text" mark
    And I should see the photo with the "text"
    Then I select "Background color"
    Then I should see the following "Background Colors" in the screen:
    | White      |
    | Gray       |
    | Black      |
    | Light blue |
    | Blue       |
    | Purple     |
    | Orchid     |
    | Pink       |
    | Red        |
    | Orange     |
    | Gold       |
    | Yellow     |
    | Olive      |
    | Green      |
    | Aquamarin  |
  
@done
Scenario: Verify all the background colors are applied successfully
    Given I am on the "TextEdit" screen for "CameraRoll Preview" 
    And I enter unique text
    Then I tap "Add text" mark
    And I should see the photo with the "text"
    Then I select "Background color"
    Then I verify that all the "Background colors" are applied successfully

    
    
    