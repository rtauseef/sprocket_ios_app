Feature: Check Paper size and Paper type
    As a user
    I want to Check and Verify Paper size and Paper type


    @TA17800
    Scenario: Verify print metrics
        Given I am on the "CameraRoll Photo" screen
        And  I touch menu button on navigation bar
        When I touch "About"
		Then I should see the "About" screen 
        And I get the version
        Then I touch "Done"
        Then I touch menu button on navigation bar
        Then I should see the "CameraRoll Photo" screen
        When I touch a photos in Camera Roll photos
        Then I should see the "CameraRoll Preview" screen
        When I tap "Download" button
		Then I wait for some seconds
        Then Fetch metrics details
        And I check the photo_source is "Camera Roll"
        And I check the off ramp is "PGSaveToCameraRollActivity"
        Then I check Timestamp
        And I check the product name is "sprocket"
        And I check the version
        And I check the os_type is "iOS"
        And I check the device type is "x86_64"
        And I check the manufacturer is "Apple"
        And I check the os version
        #And I check the wifi ssid
        And I check the device brand is "Apple"
        And I check the product id is "com.hp.dev.hp-sprocket"
        And I check the library version
        And I check the application type is "HP"
        
        
    
        
        
        