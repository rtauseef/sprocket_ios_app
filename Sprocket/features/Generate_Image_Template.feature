Feature: Generate image template
	As a user
  I want to genearte image template for image comparison 
	
  @reset
	@verify_imagetemplate_iOS
    @TA12601
    Scenario Outline: verify image template generation
		Given I am on the "Select Template" screen
    And I click on screen if coach marks are present
		When I touch the "Hemingway" template
		Then the template "Hemingway" should be selected
		And I touch Share icon
		Then I touch "Print"
		Then I run print simulator
        Then I am on the "Page Settings" screen
        And I scroll screen "down"
		And I touch "Paper Size" option
		And I should see the paper size options
		Then I selected the paper size "<size_option>"
    Then I wait for some seconds
		And I scroll down until "Simulated InkJet" is visible in the list
    Then I choose print button
		Then I wait for some seconds
    Then I generate template file
    Examples:
		| size_option |
		| 4 x 5       |
		| 4 x 6       |
		| 5 x 7       |
        
  @reset
  @verify_imagetemplate_iOS
  @TA12601
  	Scenario Outline: Verify image template generation with paper type for size "8.5 X 11"
		Given I am on the "Select Template" screen
    And I click on screen if coach marks are present
		When I touch the "Hemingway" template
		Then the template "Hemingway" should be selected
		And I touch Share icon
		Then I touch "Print"
		Then I run print simulator
        Then I am on the "Page Settings" screen
        And I scroll screen "down"
		And I touch "Paper Size" option
		And I should see the paper size options
		Then I selected the paper size "8.5 x 11"
    And I should see the paper type options
    Then I selected the paper type "<type_option>"
		  Then I wait for some seconds
		And I scroll down until "Simulated InkJet" is visible in the list
    Then I choose print button
		Then I wait for some seconds
    Then I generate template file
    Examples:
    | type_option |
		| Plain Paper |
		| Photo Paper |
        
