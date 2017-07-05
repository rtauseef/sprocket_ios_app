Feature: Check Paper size and Paper type
    As a user
    I want to Check and Verify Paper size and Paper type


    @done
    @smoke
    @regression
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
        And I check the product id is "com.hp.sprocket"
        And I check the library version
        And I check the application type is "HP"
        
        
   @TA17934
   Scenario: Verify print metrics - Print
        Given I am on the "CameraRoll Photo" screen
        And  I touch menu button on navigation bar
        When I touch "About"
		Then I should see the "About" screen 
        And I get the version
        Then I touch "Done"
        Then I touch "sprocket"
        And I touch "Printers"
        Then I get the firmware version, printer_id and tmd_version
        Then I navigate back
        And I get the printer_name
        Then I touch "Done"
        Then I touch menu button on navigation bar
        Then I should see the "CameraRoll Photo" screen
        When I touch a photos in Camera Roll photos
        Then I should see the "CameraRoll Preview" screen
        When I tap "Print" button
		Then I wait for some seconds
        Then Fetch metrics details
        And I check the photo_source is "Camera Roll"
        And I check the off ramp is "PrintWithNoUI"
        Then I check Timestamp
        And I check the product name is "sprocket"
        And I check the version
        And I check the os_type is "iOS"
        #And I check the device type is "x86_64"
        And I check the manufacturer is "Apple"
        #And I check the wifi ssid
        And I check the device brand is "Apple"
        And I check the product id is "com.hp.sprocket"
        And I check the library version
        And I check the application type is "HP"
        And I check the paper size is "2 x 3"
        And I check the paper type is "Photo Paper"
        And I check the printer_model is "HP sprocket"
        And I check the printer_name
        And I check the printer_id
        And I check the os version
        And I check the number of copies is "1"
        And I check the content type is "Image" 
        And I check the user_paper_width_inches is "2"
        And I check the user_paper_height_inches is "3"
        And I check the language code is "en"
        And I check the print_queue_id is "null"
        And I check the custom data
        And I check the route taken is "print-metrics-test.twosmiles.com"
        And I check the country code is "US"
        And I check the card is "This column has been deprecated. Use the 'template_name' column instead."
        And I check the category
        
    @TA18198
    Scenario: Verify print metrics - multiselect
        Given I am on the "CameraRoll Photo" screen
        And  I touch menu button on navigation bar
        When I touch "About"
		Then I should see the "About" screen 
        And I get the version
        Then I touch "Done"
        Then I touch "sprocket"
        And I touch "Printers"
        Then I get the firmware version, printer_id and tmd_version
        Then I wait for some seconds
        Then I navigate back
        And I get the printer_name
        Then I touch "Done"
        Then I touch menu button on navigation bar
        Then I should see the "CameraRoll Photo" screen
        And I touch "Select"
        Then I should see the multiselect option enabled
        Then I select "2" photos
        And I should see the number of photos selected as "2"
        Then I tap on the multi selected number  
        Then I should see the "CameraRoll Preview" screen
        When I tap "Print" button
		Then I wait for some seconds
        Then Fetch metrics details
        And I check the photo_source is "Camera Roll"
        And I check the off ramp is "PrintFromQueue-MultiSelect"
        Then I check Timestamp
        And I check the product name is "sprocket"
        And I check the version
        And I check the os_type is "iOS"
        #And I check the device type is "x86_64"
        And I check the manufacturer is "Apple"
        #And I check the wifi ssid
        And I check the device brand is "Apple"
        And I check the product id is "com.hp.sprocket"
        And I check the library version
        And I check the application type is "HP"
        And I check the paper size is "2 x 3"
        And I check the paper type is "Photo Paper"
        And I check the printer_model is "HP sprocket"
        And I check the printer_name
        And I check the printer_id
        And I check the os version
        And I check the number of copies is "1"
        And I check the content type is "Image" 
        And I check the user_paper_width_inches is "2"
        And I check the user_paper_height_inches is "3"
        And I check the language code is "en"
        And I check the print_queue_id is "not null"
        And I check the custom data
        And I check the route taken is "print-metrics-test.twosmiles.com"
        And I check the country code is "US"
        And I check the card is "This column has been deprecated. Use the 'template_name' column instead."
        And I check the category
        