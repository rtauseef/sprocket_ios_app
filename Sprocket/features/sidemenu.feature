Feature: Verify Side menu feature
  As a user I want to verify side menu functionality
  
@reset
@TA14291
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
      | Instagram    | Instagram Signin | Home             |
      | Flickr       | FlickrSignin     | Flickr Photo     |
      | CameraRoll   | CameraRoll       | CameraRoll Photo |

    