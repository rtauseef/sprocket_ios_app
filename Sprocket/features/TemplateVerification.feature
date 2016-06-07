  Feature: Select every templates
  As a signed in user
  I should be able to select different templates for my pictures and edit


	@reset
	@regression
	Scenario Outline: Verify text edit in different templates for instagram
		Given I am on the "Select Template" screen
		And I click on screen if coach marks are present
		When I touch the "<template_name>" template
		Then the template "<template_name>" should be selected
		And I touch the text box
		When I enter "new description"
		And I press the "Done" button
		And I should see "new description" in the text box
	Examples:
	  | template_name  |
	  | Hemingway      |
	  | Kerouac        |
	  | Asimov         |
	  | Lovecraft      |
	  | Wallace        |
	  | Ariel          |
	  | Sofia          |
	  | Jack           |
	  | Steinbeck      |
	  | Dickens        |
	  | Clean          |

	@reset
	@regression
	Scenario Outline: Verify print in different templates for instagram
		Given I am on the "Select Template" screen
		And I click on screen if coach marks are present
		When I touch the "<template_name>" template
		Then the template "<template_name>" should be selected
		When I touch Share icon
		And I touch "Print"
        Then I run print simulator
        And I scroll screen "down"
		And I should see the paper size options
		Then I selected the paper size "4 x 6"
		And I scroll down until "Simulated Laser" is visible in the list
		Then I wait for some seconds
		Then I choose print button
	Examples:
	  | template_name  |
	  | Hemingway      |
	  | Kerouac        |
	  | Asimov         |
	  | Lovecraft      |
	  | Wallace        |
	  | Ariel          |
	  | Sofia          |
	  | Jack           |
	  | Steinbeck      |
	  | Dickens        |
	  | Clean          |


	@reset
	@regression
	Scenario Outline: Verify print in different templates for Flickr
		Given I am on the "Flickr Select Template" screen
		And I click on screen if coach marks are present
		When I touch the "<template_name>" template
		Then the template "<template_name>" should be selected
		When I touch Share icon
		And I touch "Print"
        Then I run print simulator
        And I scroll screen "down"
		And I should see the paper size options
		Then I selected the paper size "5 x 7"
        And I scroll down until "Simulated Laser" is visible in the list
		Then I wait for some seconds
		Then I choose print button
	Examples:
	  | template_name  |
	  | Hemingway      |
	  | Kerouac        |
	  | Asimov         |
	  | Lovecraft      |
	  | Wallace        |
	  | Ariel          |
	  | Sofia          |
	  | Jack           |
	  | Steinbeck      |
	  | Dickens        |
	  | Clean          |


	@reset
	@regression
	Scenario Outline: Verify print in different templates for Camera Roll
		Given I am on the "CameraRoll Select Template" screen
		And I click on screen if coach marks are present
		When I touch the "<template_name>" template
		Then the template "<template_name>" should be selected
		When I touch Share icon
		And I touch "Print"
        Then I run print simulator
        And I scroll screen "down"
		And I should see the paper size options
		Then I selected the paper size "8.5 x 11"
        And I scroll down until "Simulated Laser" is visible in the list
		Then I wait for some seconds
		Then I choose print button
	Examples:
	  | template_name  |
	  | Hemingway      |
	  | Kerouac        |
	  | Asimov         |
	  | Lovecraft      |
	  | Wallace        |
	  | Ariel          |
	  | Sofia          |
	  | Jack           |
	  | Steinbeck      |
	  | Dickens        |
	  | Clean          |


	@reset
	@regression
	Scenario: Select a Photo and print all templates in 4 x 6 paper size
	  Given I am on the "Flickr Select Template" screen
	  And I click on screen if coach marks are present
	  Then I "Print" all templates in "4 x 6" paper size with "Simulated Laser" printer

	@reset
	@regression
	Scenario: Print all templates from Instagram
	  Given I am on the "Select Template" screen
	  And I click on screen if coach marks are present
	  Then I "Print" all templates in "5 x 7" paper size with "Simulated Laser" printer

	@reset
	@regression
	Scenario: Print all templates from Camera Roll
	  Given I am on the "CameraRoll Select Template" screen
	  And I click on screen if coach marks are present
	  Then I "Print" all templates in "8.5 x 11" paper size with "Simulated Laser" printer