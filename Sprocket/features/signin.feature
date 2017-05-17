Feature: Signin to social media
  As a user
  I want to signin to social media account from Landing Page
  
  
@reset
@regression
@TA17951
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
      | social_media | welcome             | Sign in          | Photos           |
      | Instagram    | Instagram Landing   | Instagram Signin | Instagram Photos |
      | Google       | Google Landing      | Google Signin     | Google Photos     |
     
    
      
@reset
@done
@smoke
Scenario: Open Cameraroll from Landing screen
    Given I am on the "Landing" screen
    Then I should see "CameraRoll" logo
    And I click on the "CameraRoll" logo
    Then I should see the "CameraRoll Landing" screen
    And I click on the "Sign in" button
    Then I should see the "CameraRoll Photo" screen
    
    

    