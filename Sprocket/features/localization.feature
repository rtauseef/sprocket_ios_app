Feature: Localization testing
  As a user
  I want to change iPhone language and verify screen titles

  @reset
  @TA15895
  Scenario: Change iPhone Language
    Given  I am on the "Landing" screen
    Then I change the language
        
  @TA15895
  Scenario: Verify screen titles
    Given  I am on the "CameraRollLanding" screen
    Then I open cameraroll	
    Then I verify photos screen title
    
 @TA15895
 Scenario: Verify landing screen texts
    Given  I am on the "Landing" screen
    Then I verify the "Take or Select photo" text
    And I verify the "Terms and service" link
    
 @TA15895
 Scenario Outline: Verify side menu texts
    Given  I am on the "Landing" screen
    When I touch menu button on navigation bar
	Then I should see the side menu
    And I verify the "<sidemenu_options>" text
    
    Examples:
    | sidemenu_options |
    | Buy Paper        |
    | How to & Help    |
    | Give Feedback    |
    | Privacy          |
    | About            |
    | Camera Roll      |
    | Sign In          |
   

