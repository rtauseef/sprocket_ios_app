Feature: Verify Side menu feature
  As a user I want to verify side menu functionality
  
@reset
@regression
@done
Scenario Outline: Sign in to different Social media accounts from side menu
    Given I am on the "Landing" screen
    When I touch menu button on navigation bar
    Then I should see the side menu
    Then I should see "<social_media>" logo
    And I click on the "<social_media>" logo 
    Then I should see the "<Sign in>" screen
    And I enter valid credentials
    And I touch login button
    Then I should see the "<Photos>" screen
    Examples:
      | social_media | Sign in          | Photos           |
      | Instagram    | Instagram Signin | Instagram Photos |
      | Flickr       | FlickrSignin     | Flickr Photo     |
      
@reset
@regression
@done
Scenario: Sign in to different Social media accounts from side menu
    Given I am on the "Landing" screen
    When I touch menu button on navigation bar
    Then I should see the side menu
    Then I should see "CameraRoll" logo
    And I click on the "CameraRoll" logo 
    Then I should see the "CameraRoll Landing" screen
    And I click on the "Sign in" button
    Then I should see the "CameraRoll Photo" screen
      

@reset
@done
Scenario: Verify side menu options
    Given I am on the "Landing" screen
    When I touch menu button on navigation bar
    Then I should see the side menu
    And I should see the following:
    |sprocket       |
    |Buy Paper      |
    |How To & Help  |
    |Give Feedback  |
    |Privacy        |
    |About          |
    
  @reset
  @TA16064
  Scenario: Verify navigation to Technical Information screen
    Given  I am on the "Landing" screen
    When I touch menu button on navigation bar
	Then I should see the side menu
    Then I touch "sprocket"
    And I should see the technical information
    Then I touch "Technical Information"
    And I should see the "Technical Information" screen
    And I tap back button
    And I tap "Close" mark
    When I touch menu button on navigation bar
    Then I should see the "Landing" screen 
    
    
    @reset
    @done
  Scenario: Verify about screen from side menu
    Given  I am on the "Landing" screen
    When I touch menu button on navigation bar
	Then I should see the side menu
    When I touch "About"
    Then I should see the "About" screen 
    Then I should see "Sprocket" logo
    And I should see the following:
    |Version|
    |HP Development Company, L.P.|
    |Copyright (c) 2016|
    When I touch "Done"
    Then I wait for sometime
	Then I should see the side menu
    
    @reset
    @done
  Scenario: Verify closing side menu
    Given  I am on the "Landing" screen
    When I touch menu button on navigation bar
	Then I should see the side menu
    When I touch menu button on navigation bar
    Then I should see the "Landing" screen 
    