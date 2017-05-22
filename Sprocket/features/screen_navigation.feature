Feature: Verify screen navigation
  As a user I want to check default screens and other screen navigation




 @reset
 @done
 @smoke
Scenario: Verify camera roll navigation
	Given I am on the "Landing" screen
	And I tap "CameraRoll"
	And I touch the Camera Roll button
	When I touch Authorize
	Then I should see the "CameraRoll Photo" screen
	Then I touch "arrowDown"
	Then I should see the camera roll albums
	Then I touch Camera Roll Image
	And I should see the camera roll photos
	When I touch a photos in Camera Roll photos
	Then I should see the "CameraRoll Preview" screen

@reset
@done
Scenario: Verify Instagram navigation   
    Given I am on the "Landing" screen
    Then I should see "Instagram" logo
    And I click on the "Instagram" logo
    Then I should see the "Instagram Landing" screen
    And I click on the "Sign in" button
    Then I should see the "Instagram Signin" screen
    And I enter valid credentials
    And I touch login button
    Then I should see the "Instagram Photos" screen
    When I touch second photo
    Then I should see the "Instagram Preview" screen
    
    
@reset
@done
@regression
Scenario: Verify Google navigation 
    Given I am on the "Landing" screen
    Then I should see "Google" logo
    And I click on the "Google" logo
    Then I should see the "Google Landing" screen
    And I click on the "Sign in" button
    Then I should see the "Google Signin" screen
    And I enter valid credentials
    And I touch login button
    Then I should see the "Google Photos" screen
    When I touch second photo
    Then I should see the "Google Preview" screen
    

