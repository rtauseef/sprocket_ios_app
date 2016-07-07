Feature: Verify Welcome screen/Landing Page
  As a user
  I want to check elements displayed on landing page

  @reset
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



  @reset
  @TA13957
  Scenario: Verify Terms of Service link on Landing Screen
    Given  I am on the "Landing" screen
    Then I should see "sprocket"
    And I should see social source authentication text
    When I touch the Terms of Service link
    Then I should see the "Sprocket Terms Of Service" screen
    When I touch "Done" button
    Then I should see the "Landing" screen



#	*** Scenarios to Imeplement ****
#
#  Scenario: Verify Side menu from Landing screen
#	Given  I am on the "Landing" screen
#	Then I tap "Hamburger"
#	And I see side menu
#
#
#  Scenario Outline: Open Social Source from  Landing screen
#	Given  I am on the "Landing" screen
#	Then I tap "<Social Source>"
#	And I see "<Social Source>" Login screen
#	Examples:
#	|Social Source|
#	|Instagram|
#  	|Flickr|
#  	|Facebook|
#  	|Camera Roll|