Feature: Verify Side menu feature
  As a user I want to verify side menu functionality
  
@reset
@regression
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
      | Instagram    | Instagram Signin | Instagram Photos             |
      | Flickr       | FlickrSignin     | Flickr Photo     |
      | CameraRoll   | CameraRoll       | CameraRoll Photo |


@reset
@TA14381
Scenario: Verify side menu options
    Given I am on the "Landing" screen
    When I touch menu button on navigation bar
    Then I should see the side menu
    And I should see the following:
    |sprocket        |
    |Buy Paper      |
    |How To & Help  |
    |Give Feedback  |
    |Privacy        |
    |About          |
    
  @reset
  @TA14381
  Scenario: Verify navigation to device screen
    Given  I am on the "Landing" screen
    When I touch menu button on navigation bar
	Then I should see the side menu
    Then I touch "sprocket"
    And I should see the modal screen title
    And I tap the "OK" button
    Then I am on the "Device" screen
    Then I click close button
    Then I should see the side menu
    
    @reset
  @TA14381
  Scenario: Verify about screen from side menu
    Given  I am on the "Landing" screen
    When I touch menu button on navigation bar
	Then I should see the side menu
    When I touch "About"
    Then I should see the "About" screen 
    Then I should see "Sprocket" logo
    And I should see the following:
    |Version 1.0.1 (DEV)|
    |HP Development Company, L.P.|
    |Copyright (c) 2016|
    When I touch "Done"
    Then I wait for sometime
	Then I should see the side menu
    
    @reset
  @TA14381
  Scenario: Verify closing side menu
    Given  I am on the "Landing" screen
    When I touch menu button on navigation bar
	Then I should see the side menu
    When I touch menu button on navigation bar
    Then I should see the "Landing" screen 

  @reset
  @TA15036
  Scenario: Verify navigation to Help page
    Given  I am on the "Landing" screen
    When I touch menu button on navigation bar
    Then I should see the side menu
    Then I touch "How To & Help"
    And I should see the following:
    |View User Guide|
    |Tweet Support|
    |Join Support Forum|
    |Visit Support Website|

  @reset
  @TA15036
  @appium
  Scenario: Verify navigation to User Guide
    Given I am on the Landing screen
    Then I open side menu
    Then I touch the option "How To & Help"
    Then I touch the option "View User Guide"

  @TA15036
  @appium
  Scenario: Verify User guide page in browser
    Given I verify "View User Guide" navigate to the needed webpage

    @reset
  @TA15036
  @appium
  Scenario: Verify navigation to tweet support
    Given I am on the Landing screen
    Then I open side menu
    Then I touch the option "How To & Help"
    Then I touch the option "Tweet Support"

  @TA15036
  @appium
  Scenario: Verify tweet support page in browser
    Given I verify "Tweet Support" navigate to the needed webpage

     @reset
  @TA15036
  @appium
  Scenario: Verify navigation support forum
    Given I am on the Landing screen
    Then I open side menu
    Then I touch the option "How To & Help"
    Then I touch the option "Join Support Forum"

  @TA15036
  @appium
  Scenario: Verify support forum page in browser
    Given I verify "Join Support Forum" navigate to the needed webpage

    @reset
  @TA15036
  @appium
  Scenario: Verify navigation to Support Website
    Given I am on the Landing screen
    Then I open side menu
    Then I touch the option "How To & Help"
    Then I touch the option "Visit Support Website"

  @TA15036
  @appium
  Scenario: Verify Support Website page in browser
    Given I verify "Visit Support Website" navigate to the needed webpage
    