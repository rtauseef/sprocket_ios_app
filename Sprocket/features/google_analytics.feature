Feature: Verify message sent to Google Analytics on Xcode console log message
    As a user
    I should be able to open ,select and login any social media ,select photo and verify message logged on Xcode console
    
@reset
@done
Scenario: Navigate to cameraroll
    Given  I am on the "Landing" screen
    And Fetch Xcode Console Log
    And I verify log for "Landing" screen
    Then I select Instagram logo
	And I wait for some seconds
    When I touch "Sign in" button
    Then I should see the "Instagram Signin" screen
    And I fill the form with valid Instagram credentials
    When I touch Instagram Log in button
    Then I should see the "Home" screen
    When I touch second photo
    Then I should see the "Select Template" screen
    And I click on screen if coach marks are present
    When I touch the "Clean" template
    And I check log for selected template as "Clean"
    And I touch Share icon
    When I touch "Save to Camera Roll"
    And I verify log for camera roll

    @reset
@regression
Scenario Outline: Navigate to print
    Given I am on the "Home" screen
    When I touch second photo
    Then I should see the "Select Template" screen
    And I click on screen if coach marks are present
    When I touch the "Clean" template
    And I touch Share icon
    And I touch "Print"
    And I scroll screen "down"
    And I touch "Paper Size" option
    Then I run print simulator
    And I should see the paper size options
    Then I selected the paper size "<size_option>"
    And I scroll down until "Simulated Laser" is visible in the list
	Then I wait for some seconds
	Then I choose print button
    Then I wait for some seconds
    And Fetch Xcode Console Log
    And I verify log for "Print" and selected paper size "<size_option>"
     Examples:
		| size_option          |
		| 4 x 5  |
		| 4 x 6       |
		| 5 x 7       |
  
@reset
@done
Scenario Outline: Navigate to print
    Given I am on the "Home" screen
    When I touch second photo
    Then I should see the "Select Template" screen
    And I click on screen if coach marks are present
    When I touch the "Clean" template
    And I touch Share icon
    And I touch "Print"
    And I scroll screen "down"
    And I touch "Paper Size" option
    Then I run print simulator
    And I should see the paper size options
    Then I selected the paper size "8.5 x 11"
    And I should see the paper type options
    Then I selected the paper type "<type_option>"
    And I scroll down until "Simulated Laser" is visible in the list
    Then I wait for some seconds
    Then I choose print button
    Then I wait for some seconds
    And Fetch Xcode Console Log
    And I verify log for "Print" and selected paper type "<type_option>"
     Examples:
		| type_option          |
		| Photo Paper |
		| Plain Paper      |

@reset
@done
Scenario: Verify Print Cancel log
    Given I am on the "Home" screen
    When I touch second photo
    Then I should see the "Select Template" screen
    And I click on screen if coach marks are present
    When I touch the "Clean" template
    And I touch Share icon
    And I touch "Print"
    Then I cancel print 
    Then I wait for some seconds
    And Fetch Xcode Console Log
    And I verify log for print cancelled
    



