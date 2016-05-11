Feature: Check Paper size and Paper type
    As a user
    I want to Check and Verify Paper size , Paper quality and Print image 
	
	@reset
	@ios_printersimulator_checked
	@verifysize_printersimulator
	Scenario Outline: verify paper size with printer simulator checked
		Given I am on the "Select Template" screen
		And I click on screen if coach marks are present
		When I touch the "Hemingway" template
		Then the template "Hemingway" should be selected
		And I touch Share icon
		Then I touch "Print"
		Then I open printer simulator
		Then I click load paper
		And I check paper size sensor of printer "Simulated InkJet"
		Then I clear log in printer stimulator
		And I should see the paper size options
		Then I selected the paper size "<size_option>"
		#Then I should see printer details
    Then I wait for some seconds
    And I scroll down until "Simulated InkJet" is visible in the list
    Then I choose print button
		Then I wait for some seconds
		Then I save log of printer simulator
		And Fetch values from printer simulator log
		And I check the paper size is "<size_option>" from log
		And I check the paper type is "Photo Paper"
		Then I check whether template is available for given settings
		Then I compare generated PDF with the template
		Then I wait for some seconds
    Examples:
		| size_option          |  
		| 4 x 6       |
		| 5 x 7       |
		| 4 x 5       |
    
	@reset    
	@ios_printersimulator_checked    
	@verifyquality_printersimulator
	Scenario Outline: verify paper quality with printer simulator checked
		Given I am on the "Select Template" screen
		And I click on screen if coach marks are present
		When I touch the "Hemingway" template
		Then the template "Hemingway" should be selected
		And I touch Share icon
		Then I touch "Print"
		Then I open printer simulator
		Then I click load paper
		And I check paper size sensor of printer "Simulated InkJet"
		Then I clear log in printer stimulator
		And I should see the paper size options
		Then I selected the paper size "8.5 x 11"
		And I should see the paper type options
		Then I selected the paper type "<type_option>"
		#Then I should see printer details
    Then I wait for some seconds
    And I scroll down until "Simulated InkJet" is visible in the list
    Then I choose print button
		Then I wait for some seconds
		Then I save log of printer simulator
		And Fetch values from printer simulator log
		And I check the paper type is "<type_option>"
		Then I check whether template is available for given settings
		Then I compare generated PDF with the template
		Then I wait for some seconds
	Examples: 
		| type_option |
		| Plain Paper |
		| Photo Paper |
		
	@reset
	@ios_printersimulator_unchecked
	@verifysize_printersimulator
	Scenario Outline: verify paper quality with printer simulator checked
		Given I am on the "Select Template" screen
		And I click on screen if coach marks are present
		When I touch the "Hemingway" template
		Then the template "Hemingway" should be selected
		And I touch Share icon
		Then I touch "Print"
		Then I open printer simulator
		Then I click load paper
		And I uncheck paper size sensor of printer "Simulated InkJet"
		Then I clear log in printer stimulator
		And I should see the paper size options
		Then I selected the paper size "<size_option>"
		#Then I should see printer details
    Then I wait for some seconds
    And I scroll down until "Simulated InkJet" is visible in the list
    Then I choose print button
		Then I wait for some seconds
		Then I save log of printer simulator
		And Fetch values from printer simulator log
		And I check the paper size is "<size_option>" from log
		And I check the paper type is "Photo Paper"
		Then I check whether template is available for given settings
		Then I compare generated PDF with the template
		Then I wait for some seconds
    Examples:
		| size_option          |  
		| 4 x 6       |
		| 5 x 7       |
		| 4 x 5       |
    
	@reset    
	@ios_printersimulator_unchecked    
	@verifyquality_printersimulator
	Scenario Outline: verify paper quality with printer simulator unchecked
		Given I am on the "Select Template" screen
		And I click on screen if coach marks are present
		When I touch the "Hemingway" template
		Then the template "Hemingway" should be selected
		And I touch Share icon
		Then I touch "Print"
		Then I open printer simulator
		Then I click load paper
		And I uncheck paper size sensor of printer "Simulated InkJet"
		Then I clear log in printer stimulator
		And I should see the paper size options
		Then I selected the paper size "8.5 x 11"
		And I should see the paper type options
		Then I selected the paper type "<type_option>"
		#Then I should see printer details
    Then I wait for some seconds
    And I scroll down until "Simulated InkJet" is visible in the list
    Then I choose print button
		Then I wait for some seconds
		Then I save log of printer simulator
		And Fetch values from printer simulator log
		And I check the paper type is "<type_option>"
		Then I check whether template is available for given settings
		Then I compare generated PDF with the template
		Then I wait for some seconds
	Examples: 
		| type_option |
		| Plain Paper |
		| Photo Paper |
		
