Feature: Check Print Queue functionality
    As a user
    I want to Check add, delete jobs to Print Queue and corresponding print metrics



    @reset
    @done
    @regression
    Scenario: Verify AddToQueue-Single, DeleteToQueue-Single and corresponding metrics
        Given I am on the "CameraRoll Preview" screen
        When I tap "Print" button
		Then I wait for some seconds
        And I touch "OK"
        And I should see "Print Queue" with "1" items and a right arrow
        Then I wait for some seconds
        Then Fetch metrics details
        And I check the photo_source is "Camera Roll"
        And I check the off ramp is "AddToQueue-Single"
        Then I check Timestamp
        And I check the product name is "sprocket"
        And I check the os_type is "iOS"
        And I check the device type is "x86_64"
        And I check the manufacturer is "Apple"
        And I check the os version
        And I check the wifi ssid
        And I check the device brand is "Apple"
        And I check the product id is "com.hp.sprocket"
        And I check the library version
        And I check the application type is "HP"
        Then I select "printqueue" 
        And I touch "Delete All"
        Then I wait for some seconds
        And I touch "Yes"
        Then I wait for some seconds
        Then Fetch metrics details
        And I check the photo_source is "Camera Roll"
        And I check the off ramp is "DeleteFromQueue-MultiSelect"
        Then I check Timestamp
        And I check the product name is "sprocket"
        And I check the os_type is "iOS"
        And I check the device type is "x86_64"
        And I check the manufacturer is "Apple"
        And I check the os version
        And I check the wifi ssid
        And I check the device brand is "Apple"
        And I check the product id is "com.hp.sprocket"
        And I check the library version
        And I check the application type is "HP"


  @reset
  @done
  @regression
  Scenario: Verify AddToQueue-Multi, DeleteToQueue-Multi and corresponding metrics
    Given I am on the "CameraRoll Photo" screen
    And I touch "Select"
    Then I should see the multiselect option enabled
    Then I select "3" photos
    And I should see the number of photos selected as "3"
    Then I tap on the multi selected number  
    Then I should see the "CameraRoll Preview" screen
    When I tap "Print" button
    Then I wait for some seconds
    And I touch "OK"
    And I should see "Print Queue" with "3" items and a right arrow
    Then I wait for some seconds
    Then Fetch metrics details
    And I check the photo_source is "Camera Roll"
    And I check the off ramp is "AddToQueue-MultiSelect"
    Then I check Timestamp
    And I check the product name is "sprocket"
    And I check the os_type is "iOS"
    And I check the device type is "x86_64"
    And I check the manufacturer is "Apple"
    And I check the os version
    And I check the wifi ssid
    And I check the device brand is "Apple"
    And I check the product id is "com.hp.sprocket"
    And I check the library version
    And I check the application type is "HP"
    Then I select "printqueue" 
    And I touch "Delete All"
    And I wait for some seconds
    And I touch "Yes"
    Then I wait for some seconds
    Then Fetch metrics details
    And I check the photo_source is "Camera Roll"
    And I check the off ramp is "DeleteFromQueue-MultiSelect"
    Then I check Timestamp
    And I check the product name is "sprocket"
    And I check the os_type is "iOS"
    And I check the device type is "x86_64"
    And I check the manufacturer is "Apple"
    And I check the os version
    And I check the wifi ssid
    And I check the device brand is "Apple"
    And I check the product id is "com.hp.sprocket"
    And I check the library version
    And I check the application type is "HP"

        
        
    
        
        
        