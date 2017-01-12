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
    
    



    


