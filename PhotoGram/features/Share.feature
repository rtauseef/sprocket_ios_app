  Feature:Photo Share
	As a user I want to share my edited photo by mail,Print or Save to Camera Roll


	@reset
	@regression
	Scenario: Photo share options
		Given I am on the "Select Template" screen
		When I touch Share icon
		Then I should see the "Share" screen


	@reset
	@regression
	Scenario:Photo share by mail
		Given I am on the "Share" screen
		When I touch "Mail"
		Then I should see the "Mail" screen


	@reset
	@regression
	Scenario:Photo print
		Given I am on the "Share" screen
		When I touch "Print"
		Then I should see the "Page Settings" screen

	@reset
	@regression
	Scenario:Save to Camera Roll
		Given I am on the "Share" screen
		When I touch "Save to Camera Roll"
		Then I should see the "Select Template" screen

	@reset
	@regression
	Scenario:Cancel the Share
		Given I am on the "Share" screen
		When I cancel the share
		Then I should see the "Select Template" screen
