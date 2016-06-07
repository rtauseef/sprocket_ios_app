Feature: Check Paper size and Paper type
    As a user
    I want to Check and Verify Paper size and Paper type


    @ios8
    @reset
    @ios8_metrics
    @done
    Scenario Outline: Verify print metrics
        Given I am on the "Home" screen
        And  I touch menu button on navigation bar
        When I touch "About"
		Then I should see the "About" screen 
        And I get the version
        Then I touch "Done"
        Then I touch menu button on navigation bar
        Then I should see the "Home" screen
        When I touch second photo
        Then I should see the "Select Template" screen        
        And I click on screen if coach marks are present
        When I touch the "Asimov" template
        Then I get the username and photo_location on photo
        When I touch the text area on image
		Then I should see the "Text Editor" screen
        When I enter unique text
		And I press the "Done" button
		And I touch Share icon
		And I touch "Print"
        Then I run print simulator
        And I scroll screen "down"
        Then I should see the "Page Settings" screen
		When I touch "Increment" and check number of copies is 2
        And I scroll screen "down"
		When I touch switch
		Then switch should turn ON
        And I touch "Paper Size" option
		And I should see the paper size options
		Then I selected the paper size "<size_option>"
        And I should see the paper type options
		Then I selected the paper type "<type_option>"
        Then I wait for some seconds
		And I scroll down until "Simulated Laser" is visible in the list
        And I get the printer_name
		Then I touch Print button labeled "Print 2 Pages"
		Then I wait for some seconds
        Then Fetch metrics details
        And I check the number of copies is "2"
        And I check the manufacturer is "Apple"
        And I check the os_type is "iOS"
        And I check the version
        And I check black_and_white_filter value is "1"
        And I check the printer_location
        And I check the printer_model is "Simulated Laser"
        And I check the printer_name
        #And I check the image_url
        And I check the photo_source is "Instagram"
        And I check the template name is "Asimov"
        And I check the template text
        #And I check the template_text eliminates special characters and enters rest of the text
        And I check the template_text_edited is "Yes"
        And I check the user_id is "2080282854"
        And I check the user_name on photo
        #And I check the photo_location on photo
        And I check the photo_location_edited is "No"
        And I check the paper size is "<size_option>"
        And I check the paper type is "<type_option>"
		And I check the product name is "HP Snapshots"
		And I check the device brand is "Apple"
		And I check the off ramp is "PrintFromShare"
		And I check the photo source is "Instagram"
		And I check the device type is "x86_64"
		And I check the os version
        And I check the product id is "com.hp.dev.PhotoGram-cal"
        And I check the library version
        And I check the application type is "HP"
        And I check the route taken is "print-metrics-test.twosmiles.com"
        And I check the template position
        And I check the content type is "Image"
        And I check the wifi ssid
        And I delete printer simulater generated files        
		Then I wait for some seconds
        
        Examples:
		| size_option | type_option        |
		| 4 x 5       | Photo Paper        |
        | 8.5 x 11    | Plain Paper        |


    @ios8
    @reset
    @ios8_metrics
    @done
    Scenario: Emoji text scenario in print metrics
        Given I am on the "Text Editor" screen
        When I enter an emoji text
        And I press the "Done" button
		And I touch Share icon
		And I touch "Print"
        Then I run print simulator		
        Then I wait for some seconds
		And I scroll down until "Simulated InkJet" is visible in the list
        Then I click print button
		Then I wait for some seconds
        Then Fetch metrics details
        And I check the template_text eliminates special characters and enters rest of the text


    @ios7
    @reset
    @ios7_metrics
    @done
    Scenario Outline: Verify print metrics
        Given I am on the "Home" screen
        And  I touch menu button on navigation bar
        When I touch "About"
		Then I should see the "About" screen 
        And I get the version
        Then I touch "Done"
        Then I touch menu button on navigation bar
        Then I should see the "Home" screen
        When I touch second photo
        Then I should see the "Select Template" screen        
        And I click on screen if coach marks are present
        When I touch the "Asimov" template
        Then I get the username and photo_location on photo
        When I touch the text area on image
		Then I should see the "Text Editor" screen
        When I enter unique text
		And I press the "Done" button
		And I touch Share icon
		And I touch "Print"
        Then I run print simulator
        And I scroll screen "down"
        Then I should see the "Page Settings" screen
        And I touch "Paper Size" option
		And I should see the paper size options
		Then I selected the paper size "<size_option>"
        And I should see the paper type options
		Then I selected the paper type "<type_option>"
        And I touch "Print"
        Then I wait for some seconds
		And I scroll down until "Simulated Laser" is visible in the list
        Then I choose print button
		Then I wait for some seconds
        Then Fetch metrics details
        And I check the manufacturer is "Apple"
        And I check the os_type is "iOS"
        And I check the version
       # And I check the image_url
        And I check the photo_source is "Instagram"
        And I check the template name is "Asimov"
        And I check the template text
        And I check the template_text_edited is "Yes"
        And I check the user_id is "2080282854"
        And I check the user_name on photo
        #And I check the photo_location on photo
        And I check the photo_location_edited is "No"
        And I check the paper size is "<size_option>"
        And I check the paper type is "<type_option>"        
		And I check the product name is "HP Snapshots"
		And I check the device brand is "Apple"
		And I check the off ramp is "PrintFromShare"
		And I check the photo source is "Instagram"
		And I check the device type is "x86_64"
		And I check the os version
        And I check the product id is "com.hp.dev.PhotoGram-cal"
        And I check the library version
        And I check the application type is "HP"
        And I check the route taken is "print-metrics-test.twosmiles.com"
        And I check the template position
        And I check the content type is "Image"
        And I check the wifi ssid
		And I delete printer simulater generated files
		Then I wait for some seconds
        
        Examples:
		| size_option | type_option        |
		| 5 x 7       | Photo Paper      |
        | 8.5 x 11    | Plain Paper        |

        
    
