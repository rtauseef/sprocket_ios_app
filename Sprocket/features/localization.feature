Feature: Localization testing
  As a user
  I want to change iPhone language and verify screen titles

  @reset
  @TA15895
  Scenario: Change iPhone Language
    Given  I am on the "Landing" screen
    Then I change language
        
  @TA15895
  Scenario: Verify screen titles
    Given  I am on the "CameraRollLanding" screen
    Then I open cameraroll	
    Then I verify photos screen title

  

