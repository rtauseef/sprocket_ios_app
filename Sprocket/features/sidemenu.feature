Feature: Verify Side menu feature
  As a user I want to verify side menu functionality
  
@reset
@done
Scenario Outline: Sign in to different Social media accounts from side menu
    Given I am on the "Landing" screen
    When I touch menu button on navigation bar
    Then I should see the side menu
    Then I should see "<social_media>" logo
    And I click on the "<social_media>" logo 
    Then I should see the "<Sign in>" screen
    And I enter valid credentials
    And I touch login button
    Then I should see the "<Photos>" screen
    Examples:
      | social_media | Sign in          | Photos           |
      | Instagram    | Instagram Signin | Instagram Photos |
      | Google        | Google Signin     | Google Photos     |
      
@regression
Scenario: Open cameraroll from side menu
    Given I am on the "Landing" screen
    When I touch menu button on navigation bar
    Then I should see the side menu
    Then I should see "CameraRoll" logo
    And I click on the "CameraRoll" logo 
    Then I should see the "CameraRoll Landing" screen
    And I click on the "Sign in" button
    Then I should see the "CameraRoll Photo" screen
      
@done
@smoke
Scenario: Verify side menu options
    Given I am on the "Landing" screen
    When I touch menu button on navigation bar
    Then I should see the side menu
    And I should see the following:
    |sprocket       |
    |Print Queue    |
    |Buy Paper      |
    |How to & Help  |
    |Take Survey    |
    |Privacy        |
    |About          |
    
    
@done
Scenario: Verify How to & Help options
    Given  I am on the "Landing" screen
    When I touch menu button on navigation bar
	Then I should see the side menu
    Then I touch "How to & Help"
    And I should see the following:
    | Reset Sprocket Printer |
    | Setup Sprocket Printer |
    | View User Guide        |
    | Tweet Support          |
    | Join Support Forum     |
    | Visit Support Website  |
    And I touch "Done"
    Then I should see the side menu
    
@regression
Scenario Outline: Verify printer options for How to & Help
    Given  I am on the "Landing" screen
    When I touch menu button on navigation bar
	Then I should see the side menu
    Then I touch "How to & Help"
    And I touch "<Sprocket_printer_option>"
    And I should see the "<Sprocket_printer_option>" screen
    
    Examples:
    | Sprocket_printer_option| 
    | Reset Sprocket Printer | 
    | Setup Sprocket Printer | 
    
    
@done
Scenario Outline: Verify successful navigation for How to & Help options
    Given  I am on the "Landing" screen
    When I touch menu button on navigation bar
	Then I should see the side menu
    Then I touch "How to & Help"
    And I touch "<Option>"
    And I should make sure there is no app crash
    
    Examples:
    | Option                 |
    | View User Guide        |
    | Tweet Support          |
    | Join Support Forum     |
    | Visit Support Website  |
    

       
    @done
    Scenario: Verify about screen from side menu
        Given  I am on the "Landing" screen
        When I touch menu button on navigation bar
        Then I should see the side menu
        When I touch "About"
        Then I should see the "About" screen 
        Then I should see "Sprocket" logo
        And I should see the following:
        |Version|
        |HP Development Company, L.P.|
        |Copyright (c) 2016|
        When I touch "Done"
        Then I wait for sometime
        Then I should see the side menu
    
    @regression
    Scenario: Verify closing side menu
        Given  I am on the "Landing" screen
        When I touch menu button on navigation bar
        Then I should see the side menu
        When I touch menu button on navigation bar
        Then I should see the "Landing" screen 

    
    @done
    Scenario: Verify Sprocket screen options
        Given  I am on the "Landing" screen
        When I touch menu button on navigation bar
        Then I should see the side menu
        Then I touch "sprocket"
        Then I should see the "Sprocket" screen
        And I should see the following:
        | App Settings |
        | Printers     | 

    @done
    Scenario: Verify navigation to Technical Information screen
        Given  I am on the "Landing" screen
        When I touch menu button on navigation bar
        Then I should see the side menu
        Then I touch "sprocket"
        Then I should see the "Sprocket" screen
        Then I touch "Printers"
        And I should see the technical information
        Then I touch "Technical Information"
        And I should see the "Technical Information" screen
        And I tap back button
        And I tap "Close" mark
        And I touch "Done"
        When I touch menu button on navigation bar
        Then I should see the "Landing" screen 
        

	@regression
	Scenario: Instagram Sign Out from Side menu
		Given I am on the "Instagram Photos" screen
		And  I touch menu button on navigation bar
		When I touch Instagram "Sign Out" button
	    And I click Sign Out button on popup
		Then I should see Instagram "Sign In" button

 @reset
 @appium
 @TA17541
  Scenario: Signin to Facebook
    Given I am on the Landing screen
    When I touch the "Photos" Logo
    And I touch signin button
    When I touch hamburger button on navigation bar
    And I select "Buy Paper" option
    Then I verify the url

    @TA18215
    @screenshot
    Scenario Outline: Take screenshots of all the screens
        Given  I am on the "<screen_name_sprocket>" screen
        And I take screenshot of "<screen_name_sprocket>" screen
        Examples:
        |screen_name_sprocket  | 
        |Landing               | 
        |Instagram Landing     |
        |Instagram Signin      |
        |Google Landing        |
        |CameraRoll Albums     |
        |CameraRoll Photo      | 
        |Side Menu             |
        |Instagram Preview     |
        |Google Preview        |
        |CameraRoll Preview    |
        |Edit                  |
        |Share                 |
        |Filter Editor         |
        |Crop Editor           |
        |Frame Editor          |
        |Sticker Editor        |
        |Text Edit             |
        |About                 |
        |Facebook Landing      |
        |Reset Sprocket Printer|
        |Setup Sprocket Printer|
        |Sprocket              |
        |Sticker Option Editor |
        |Survey                |
        |Technical Information |
        |Text Option Editor    |

     @TA18215
     @screenshot
    Scenario: Take screenshots of all the screens
        Given  I am on the "Landing" screen
        Then I zip the "screenshot" folder
