  Feature: Edit photo text
  As a user
  I want to edit the photo text
  In order to make it special


	@regression
	Scenario: Navigate to Text Editor by clicking inside text area on image
		Given I am on the "Select Template" screen
		And I click on screen if coach marks are present
		When I touch the text area on image
		Then I should see the "Text Editor" screen


	@regression
	Scenario: Leave Text Editor screen
		Given I am on the "Text Editor" screen
		When I touch the "Done" button
		Then I should see the "Select Template" screen


	@done
	@reset
	@smoke
	Scenario: Edit cards text
		Given I am on the "Text Editor" screen
		When I enter description
		And I touch the "Done" button
		Then I should see the "Select Template" screen
		And I should see description in the text box


