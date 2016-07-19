Feature: Signin to social media
  As a user
  I want to signin to social media account from Landing Page
  
  
@reset
@done
Scenario Outline: Sign in to different Social media accounts from Landing screen
    Given I am on the "Landing" screen
    Then I should see "<social_media>" logo
    And I click on the "<social_media>" logo
    Then I should see the "<welcome>" screen
    And I click on the "Sign in" button
    Then I should see the "<Sign in>" screen
    And I enter valid credentials
    And I touch login button
    Then I should see the "<Photos>" screen
    
    
    Examples:
      | social_media | welcome            | Sign in          | Photos           |
      | Instagram    | Welcome            | Instagram Signin | Home             |
      | Flickr       | Flickr Landing     | FlickrSignin     | Flickr Photo     |
      | CameraRoll   | CameraRoll Landing | CameraRoll       | CameraRoll Photo |
      
      

    