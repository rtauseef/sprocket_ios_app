Feature: Localization testing
  As a user
  I want to change iPhone language and verify screen titles

@reset
@localization
Scenario: Verify Landing screen texts
    Given I am on the "Landing" screen
    And I should see the below listed social media texts:
    | Instagram              |
    | Facebook               |
    | Pitu                   |
    | Qzone                  |
    | Flickr                 |
    | CameraRoll             |
    | Take or select a photo |
    | Terms and service      |
    

@localization
Scenario: Verify Terms of Service link from social media landing screens
    Given I am on the "Landing" screen
    Then I should see "Instagram" logo
    And I click on the "Instagram" logo
    And I verify the Terms of Service link for "Instagram"
    Then I swipe to see "Camera Roll" screen
    And I verify the Terms of Service link for "Camera Roll"
    Then I wait for some time
    Then I swipe to see "Flickr" screen
    And I verify the Terms of Service link for "Flickr"
    Then I wait for some time
    Then I swipe to see "QZone" screen
    And I verify the Terms of Service link for "QZone"
    Then I wait for some time
    Then I swipe to see "pitu" screen
    And I verify the Terms of Service link for "pitu"
    Then I wait for some time
    Then I swipe to see "facebook" screen
    And I verify the Terms of Service link for "facebook"
    
    
    
    

@localization
Scenario: Verify camera roll authorization popup
    Given I am on the "Landing" screen
    And I touch "cameraLanding" button
    Then I should see the popup message for the "camera access"
    Then I verify the "title" of the popup message for "cameraLanding"
    And I verify the "content" of the popup message for "cameraLanding"
    And  I should see the below listed buttons:
    | Cancel   | 
    | Settings |
    
        

  @localization
  Scenario: Verify camera roll screen titles
    Given  I am on the "CameraRollLanding" screen
    Then I open cameraroll	
    Then I verify photos screen title
    

 @localization
 Scenario: Verify side menu options
    Given  I am on the "Landing" screen
    When I touch menu button on navigation bar
	Then I should see the side menu
    And I should see the below listed side menu texts:
    | Buy Paper        |
    | How to & Help    |
    | Give Feedback    |
    | Privacy          |
    | About            |
    | Camera Roll      |
    | Sign In          |
    

@localization
Scenario: Verify side menu-how to &help options
    Given  I am on the "Landing" screen
    When I touch menu button on navigation bar
	Then I should see the side menu
    Then I touch the option "How to & Help" 
    And I should see the below listed How to & help options:
    | Reset Sprocket Printer |
    | Setup Sprocket Printer |
    | View User Guide        |
    | Messenger Support      | 
    | Tweet Support          |
    | Join Support Forum     |
    | Visit Support Website  |
    | Give Feedback          |
    
    

@localization
Scenario Outline: Verify Sprocket setup reset screens navigation and titles
    Given  I am on the "Landing" screen
    When I touch menu button on navigation bar
	Then I should see the side menu
    Then I touch the option "How to & Help"
    And I touch the option "<how_to_and_help_options>"
    And I should see the "<how_to_and_help_options>" screen
    
    Examples:
    | how_to_and_help_options| 
    | Reset Sprocket Printer | 
    | Setup Sprocket Printer | 


@localization
Scenario Outline: Verify how to &help options navigation and screen titles
    Given  I am on the "Landing" screen
    When I touch menu button on navigation bar
	Then I should see the side menu
    Then I touch the option "How to & Help"
    And I touch the option "<how_to_help_options>"
    And I should make sure there is no app crash
    
    Examples:
    | how_to_help_options    |
    | View User Guide        |
    | Messenger Support      | 
    | Tweet Support          |
    | Join Support Forum     |
    | Visit Support Website  |
    | Give Feedback          |

    

@localization
Scenario: Verify Social media screen titles and navigation
    Given  I am on the "Landing" screen
    Then I should see "Instagram" logo
    And I click on the "Instagram" logo 
    Then I swipe to see "Camera Roll" screen
    Then I wait for some time
    Then I swipe to see "Flickr" screen
    Then I wait for some time
    Then I swipe to see "QZone" screen
    Then I wait for some time
    Then I swipe to see "pitu" screen
    Then I wait for some time
    Then I swipe to see "facebook" screen
    
    

@localization
Scenario: Verify localization of Terms of Service link on Landing Screen
    Given  I am on the "Landing" screen
    And I touch the Terms of Service link
    Then I should see the "Sprocket Terms Of Service" screen
    Then I touch "Done" option in the screen
    Then I should see the "Landing" screen
    

@localization
    Scenario: Verify about screen localization
        Given  I am on the "Landing" screen
        When I touch menu button on navigation bar
        Then I should see the side menu
        Then I touch "About" option in the screen
        Then I should see the "About" screen 
        Then I should see "Sprocket" logo
        And I should see the below listed about screen texts:
        |Version|
        |HP Development Company, L.P.|
        |Copyright (c) 2016|
        Then I touch "Done" option in the screen
        Then I wait for sometime
        Then I should see the side menu
    
    

@localization
Scenario: Verify Sprocket screen options localization
        Given  I am on the "Landing" screen
        When I touch menu button on navigation bar
        Then I should see the side menu
        Then I touch "sprocket" option in the screen
        Then I should see the "Sprocket" screen
        And I should see the below listed sprocket screen texts:
        | App Settings |
        | Printers     | 
    
    

@localization
Scenario: Verify Technical Information screen navigation and localization
        Given  I am on the "Landing" screen
        When I touch menu button on navigation bar
        Then I should see the side menu
        Then I touch "sprocket" option in the screen 
        Then I should see the "Sprocket" screen
        Then I touch "Printers" option in the screen
        And I should see the technical information
        Then I touch "Technical Information" option in the screen
        And I should see the "Technical Information" screen
        And I tap back button
        And I navigate back
        Then I touch "Done" option in the screen
        When I touch menu button on navigation bar
        Then I should see the "Landing" screen 
        

@block
@localization
Scenario: Navigate to Preview screen
    Given  I am on the "CameraRollLanding" screen
    Then I open cameraroll	
    When I touch second photo
    Then I should see the "CameraRoll Preview" screen
    Then I verify the "Edit" button text
    Then I tap "Download" button
    Then I should see the popup message for the "Download"
    Then I tap "Print" button
    #Then I verify the "title" of the popup message for "PrintButton"
    #And I verify the "content" of the popup message for "PrintButton"
    Then I tap "Share" button
    And I should see the below listed sprocket screen texts:
    | Save to Camera Roll |
    | Print to sprocket   |
    

@localization
Scenario: Verify localization of Instagram signin/signout buttons from sidemenu
    Given  I am on the "Landing" screen
    When I touch menu button on navigation bar
    Then I should see the side menu
    Then I should see "Instagram" logo
    And I click on the "Instagram" logo 
    Then I should see the "Instagram Signin" screen
    And I enter valid credentials
    And I touch login button
    Then I should see the "Instagram Photos" screen
    When I touch menu button on navigation bar
    Then I should see the side menu
    And I should see Instagram "Sign Out" button
    And I touch Instagram "Sign Out" button
    And I click Sign Out button on popup
    Then I should see Instagram "Sign In" button
    
    
    
    
    