Feature: Verify Welcome screen/Landing Page
  As a user
  I want to check elements displayed on landing page
  
  @reset
  @TA18418
  @reset
  Scenario: Verify sprocket intro wizard
    Given  I am on the "Intro Wizard" screen
    Then I verify the instructions to "load the paper"
    And I could see "Skip to the App" option
    Then I swipe left
    Then I verify the instructions to "power up"
    And I could see "Skip to the App" option
    Then I swipe left
    Then I verify the instructions to "connect"
    And I could see "Go to the App" option
    And I could see "More Help" option
    Then I touch "More Help"
    Then I should see "How to & Help" page
    Then I touch "Done"
    And I touch "Go to the App"
    Then I am on the "Landing" screen 
    

  @done
  @smoke
  Scenario: Verify Landing Screen
    Given  I am on the "Landing" screen
    Then I should see "sprocket"
    Then I should see "Hamburger" logo
    Then I should see "Instagram" logo
    And I should see "Facebook" logo
    Then I should see "Google" logo
    And I should see "Camera Roll" logo
    And I should see social source authentication text

  @done
  Scenario: Verify Terms of Service link on Landing Screen
    Given  I am on the "Landing" screen
    Then I should see "sprocket"
    And I should see social source authentication text
    When I touch the Terms of Service link
    Then I should see the "Sprocket Terms Of Service" screen
    When I touch "Done" button
    Then I should see the "Landing" screen

  @reset
  @done
  @smoke
  Scenario Outline: Open Social Source from  Landing screen
	Given  I am on the "Landing" screen
	Then I tap "<Social Source>"
	Then I should see the "<Social Source>Landing" screen
	
    Examples:
	|Social Source	|
	|Instagram	    |
    |Google			|
    |Facebook       |
    |CameraRoll	    |


  @regression
Scenario: Verify Side menu from Landing screen
	Given  I am on the "Landing" screen
    When I touch menu button on navigation bar
	Then I should see the side menu
 