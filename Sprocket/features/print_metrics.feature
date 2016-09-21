Feature: Verify print metrics
    As a user
    I want to verify print metrics


@reset
@TA15032
Scenario: Verify print metrics- save to cameraroll
    Given I am on the "CameraRoll Landing" screen
    And I click on the "Sign in" button
    Then I should see the "CameraRoll Photo" screen
    When I touch menu button on navigation bar
	Then I should see the side menu
    When I touch "About"
    Then I should see the "About" screen 
    And I get the version
    When I touch "Done"
    Then I wait for sometime
	Then I should see the side menu
    When I touch menu button on navigation bar
    Then I should see the "CameraRoll Photo" screen
    When I touch a photos in Camera Roll photos
    Then I am on the "CameraRoll Preview" screen
    And I close the camera pop up
    When I tap "Share" button
    Then I should see the "Share" screen
    When I touch "Save to Camera Roll"
    Then I should see the "CameraRoll Preview" screen
    Then I wait for some seconds
    Then Fetch metrics details
    And I check the photo source is "CameraRoll"
    And I check the off ramp is "PGSaveToCameraRollActivity"
    And I check the user_id is "B43057D8DE8F026EC99EA04B439F971E"
    And I check the user_name on photo is "66B95C9CADB10B8B2063612597F0FE7C"
    And I check Timestamp
    And I check the product name is "sprocket"
    And I check the version
    And I check the product id is "com.hp.dev.hp-sprocket"
    And I check the library version
    And I check the content type is "Image"
    
    

    
    
        