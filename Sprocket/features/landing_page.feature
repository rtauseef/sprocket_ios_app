Feature: Verify Welcome screen/Landing Page
  As a user
  I want to check elements displayed on landing page

  @done
  @smoke
  Scenario: Verify Landing Screen
    Given  I am on the "Landing" screen
    Then I should see "sprocket"
    Then I should see "Hamburger" logo
    Then I should see "Instagram" logo
    And I should see "Facebook" logo
    Then I should see "Flickr" logo
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
    Then I wait for sometime
	Examples:
	|Social Source	|
	|Instagram		|
  #|Flickr			|
    |Facebook		|
    |CameraRoll	    |

  @regression
Scenario: Verify Side menu from Landing screen
	Given  I am on the "Landing" screen
    When I touch menu button on navigation bar
	Then I should see the side menu
 