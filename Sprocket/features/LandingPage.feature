	Feature: Verifying different social media platform
	As a user
	I want to view different social media screens inside app

	@reset
	@done
	@smoke
	Scenario: Verify Landing Screen
		Given  I am on the "Landing" screen
		Then I should see "Instagram" logo
		And I should see "Facebook" logo
		Then I should see "Flickr" logo
		And I should see "Camera Roll" logo




