Feature: Signin with facebook credentials and verify preview options 
  
 @reset
@fbtest
  Scenario: Navigate to safari from app
    Given  I am on the "Welcome" screen
    Then I touch the next page control
    Then I wait for sometime
    Then I should navigate to facebook screen
    Then I touch "Sign in" button
   Then I wait for sometime
    

    
    @fbtest
    Scenario: Login to facebook from safari
		Given  I am on the safari screen
		And I fill the form with valid credentials for facebook
		Then I wait for sometime
        Then I click ok in confirm dialog
        

@fbtest
  Scenario: Verify margins on preview screen for facebook images
    Given  I am on the "Welcome" screen
    Then I touch the next page control
    Then I wait for sometime
    Then I should navigate to facebook screen
    Then I wait for sometime
    Then I should see the "Facebook Albums" screen
    And I select an album
    When I touch second photo
    Then I should see the "Preview" screen
    When I double tap on the picture
    Then I should see margins on top and bottom
    Then I double tap on the picture
    Then I should see the original image without margins



  