Feature: Select Photos and feed in different Views
	As a signed in user
	I should be able to select My photo and My feeds and switch between up and wide view

  @reset
	@done
	Scenario: Select My Photos and My Feeds
		Given I am on the "Home" screen
		Then I should see the "My Photos" tab Selected
		And I should see the photos listed on screen
		When I touch "My Feed"
		Then I should see the "My Feed" tab Selected
		And I should see the photos listed on screen

    @reset
	@done
	Scenario: View photos in list view and grid view
		Given I am on the "Home" screen
		Then I should see the photos in a grid view
		When I touch list mode button
		Then I should see the photos in list view


   
    @DE3143
    Scenario: Scrolling photos in My Photos and My Feed
		Given I am on the "Home" screen
		When I scroll up photos in "My Feed"
		Then I should see new photos added



