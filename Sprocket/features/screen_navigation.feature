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
@TA17012
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
@TA17012
Scenario: Verify Flickr navigation 
    Given I am on the "Landing" screen
    Then I should see "Flickr" logo
    And I click on the "Flickr" logo
    Then I should see the "Flickr Landing" screen
    And I click on the "Sign in" button
    Then I should see the "Flickr Signin" screen
    And I enter valid credentials
    And I touch login button
    Then I should see the "Flickr Photo" screen
    When I touch second photo
    Then I should see the "Flickr Preview" screen
    

@reset
@TA17012
Scenario: Verify Edit screen navigation    
    Given I am on the "CameraRoll Preview" screen
    Then I tap "Edit" button
    Then I wait for some seconds
    Then I tap "Check" mark
    Then I should see the "CameraRoll Preview" screen
    And I tap "Edit" button
    Then I wait for some seconds
    Then I tap "Close" mark
    Then I should see the "CameraRoll Preview" screen
    
    

