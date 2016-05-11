 Feature: Print Settings
 As an user
 I want to be able to select a printer, number of copies,
 So I can choose which printer can I send, the number of copies



	@reset
	@TA12601
	Scenario: Navigate to Printer Screen
		#Given I am on the "Printer Options" screen
        Given I am on the "Page Settings" screen
		When I touch "Printer"
		Then I should see the "Printer" screen


	@TA12601
	Scenario: Navigate to Printer Screen from Print Settings Screen
		Given I am on the "Print Settings" screen
		When I touch "Printer"
		Then I should see the "Printer" screen


