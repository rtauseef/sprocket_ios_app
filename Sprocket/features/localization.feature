Feature: Localization testing
  As a user
  I want to change iPhone language and verify screen titles

  @reset
  @TA15895
  @TA16511
  Scenario: Change iPhone Language
    Given  I am on the "Landing" screen
    Then I change the language
        
  @TA15895
  @TA16511
  Scenario: Verify screen titles
    Given  I am on the "CameraRollLanding" screen
    Then I open cameraroll	
    Then I verify photos screen title
    
 @TA15895
 @TA16511
 Scenario: Verify landing screen texts
    Given  I am on the "Landing" screen
    Then I verify the "Take or select a photo" text
    And I verify the "Terms and service" link
    
 @TA15895
 @TA16511
 Scenario: Verify side menu texts
    Given  I am on the "Landing" screen
    When I touch menu button on navigation bar
	Then I should see the side menu
    #And I verify the "<sidemenu_options>" text
    And I should see the below listed side menu texts:
    | Buy Paper        |
    | How to & Help    |
    | Give Feedback    |
    | Privacy          |
    | About            |
    | Camera Roll      |
    | Sign In          |
    
@TA15895
@TA16511
Scenario: Verify side menu-how to &help
    Given  I am on the "Landing" screen
    When I touch menu button on navigation bar
	Then I should see the side menu
    Then I touch the option "How to & Help"
    #And I verify the "<how_to_help_options>" text 
    And I should see the below listed How to & help options:
    | Reset Sprocket Printer |
    | Setup Sprocket Printer |
    | View User Guide        |
    | Tweet Support          |
    | Join Support Forum     |
    | Visit Support Website  |
    
@TA15895
@TA16511
Scenario Outline: Verify side menu-how to &help screen navigation
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

@TA15895
@TA16511
Scenario Outline: Verify side menu-how to &help options
    Given  I am on the "Landing" screen
    When I touch menu button on navigation bar
	Then I should see the side menu
    Then I touch the option "How to & Help"
    And I touch the option "<how_to_help_options>"
    And I should make sure there is no app crash
    
    Examples:
    | how_to_help_options    |
    | View User Guide        |
    | Tweet Support          |
    | Join Support Forum     |
    | Visit Support Website  |
    
@TA16511
Scenario: Verify Landing screen texts
    Given I am on the "Landing" screen
    And I should see the below listed social media texts:
    | Instagram  |
    | Facebook   |
    | Pitu       |
    | Qzone      |
    | Flickr     |
    | CameraRoll |
    
@TA16511
Scenario: Navigating through different Social media screens
    Given I am on the "Instagram Landing" screen
    Then I swipe to see "Camera Roll" screen
    Then I wait for some time
    Then I swipe to see "Flickr" screen
    Then I wait for some time
    Then I swipe to see "QZone" screen
    Then I wait for some time
    Then I swipe to see "pitu" screen
    Then I wait for some time
    Then I swipe to see "facebook" screen
    
    
@TA16511
Scenario: Verify localization of Terms of Service link on Landing Screen
    Given  I am on the "Landing" screen
    And I touch the Terms of Service link
    Then I should see the "Sprocket Terms Of Service" screen
    Then I touch "Done" option in the screen
    Then I should see the "Landing" screen
    
@TA16511
    Scenario: Verify about screen from side menu
        Given  I am on the "Landing" screen
        When I touch menu button on navigation bar
        Then I should see the side menu
        Then I touch "About" option in the screen
        Then I should see the "About" screen 
        Then I should see "Sprocket" logo
        And I should see the below listed about screen texts:
        |HP Development Company, L.P.|
        |Copyright (c) 2016|
        Then I touch "Done" option in the screen
        Then I wait for sometime
        Then I should see the side menu
    
    
@TA16511
Scenario: Verify Sprocket screen options
        Given  I am on the "Landing" screen
        When I touch menu button on navigation bar
        Then I should see the side menu
        #Then I touch "sprocket"
        Then I touch "sprocket" option in the screen
        Then I should see the "Sprocket" screen
        And I should see the below listed sprocket screen texts:
        | App Settings |
        | Printers     | 
    
    
@TA16511
Scenario: Verify localization of navigation to Technical Information screen
        Given  I am on the "Landing" screen
        When I touch menu button on navigation bar
        Then I should see the side menu
        #Then I touch "sprocket"
        Then I touch "sprocket" option in the screen 
        Then I should see the "Sprocket" screen
        Then I touch "Printers" option in the screen
        And I should see the technical information
        Then I touch "Technical Information" option in the screen
        And I should see the "Technical Information" screen
        And I tap back button
        And I navigate back
        Then I touch "Done"
        When I touch menu button on navigation bar
        Then I should see the "Landing" screen 
    