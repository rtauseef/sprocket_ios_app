Feature: Signin with Instagram credentials
  As a user
  I want to signin using my Instagram account
  So I don't need to go through a signup process

  @reset
  @regression
  Scenario: Navigate to Instagram Sign In
    Given I am on the "Welcome" screen
    When I touch "Sign in" button
    Then I should see the "Instagram Signin" screen

  @reset
  @regression
  @smoke
  Scenario: Signin with instagram credentials
    Given I am on the "Instagram Signin" screen
    And I fill the form with valid Instagram credentials
    When I touch Instagram Log in button
    Then I should see the "Home" screen
    
  @reset
  @regression
  Scenario: Navigate to Flicker Sign In
    Given I am on the "FlickrLanding" screen
    When I touch "Sign in" button
    Then I should see the "FlickrSignin" screen


	@reset
    @regression
	Scenario: Signin with Flicker credentials
		Given I am on the "FlickrSignin" screen
		And I fill the form with valid flicker credentials
		When I touch Flicker Log in button
		Then I should see the "FlickrAlbum" screen

  @reset
  @smoke
  Scenario: Navigate to Camera roll
    Given I am on the "CameraRollLanding" screen
    Then I should see the "CameraRoll" screen
    And I touch the Camera Roll button
    When I touch Authorize
    Then I should see the camera roll albums




