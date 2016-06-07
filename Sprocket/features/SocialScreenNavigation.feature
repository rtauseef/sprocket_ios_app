	Feature: Accessing different social media platform
	As a user
	I want to Access different social media screens inside app

	@reset
	@done
	Scenario: Navigating through different login screens
		Given  I am on the "Welcome" screen
		Then I touch the next page control
		Then I wait for some time
		Then I should navigate to facebook screen
		Then I touch the next page control
		Then I wait for some time
		Then I should navigate to Flickr photos screen
		Then I touch the next page control
		Then I wait for some time
		Then I should navigate to Social Media Snapshots screen


	  @reset
	  @regression
	Scenario: Navigation from Instagram Select Photo screen
		Given I am on the "Home" screen
		Then I touch the next page control
		Then I wait for some time
		Then I should navigate to facebook screen
		Then I touch the next page control
		Then I wait for some time
		Then I should navigate to Flickr photos screen
		Then I touch the next page control
		Then I wait for some time
		Then I should navigate to Social Media Snapshots screen

	  @reset
	  @DE2939
	Scenario: Navigation from Flickr Select Photo screen
		Given I am on the "FlickrPhoto" screen
		Then I touch the previous page control
		Then I wait for some time
		Then I should navigate to facebook screen
		Then I touch the previous page control
		Then I wait for some time
		Then I should see the "Home" screen


