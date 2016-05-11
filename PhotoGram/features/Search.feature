Feature: Search Feature
 As an user
 I want to be able to search entering hashtag or username
 So I can choose which printer can I send, the number of copies


	@done
	Scenario: Navigate to Search screen
		Given I am on the "Home" screen
		When I touch search icon
		Then I should see the "Search" screen


	@done
	Scenario: Search with Hashtag
		Given I am on the "Search" screen
		When I enter hashtag
		And I touch search
		Then I should see results
		And click on first result
		Then I should see the "HashtagSearchResult" screen



	@TA12601
	Scenario: Search with username
		Given I am on the "Search" screen
		When I enter username
		And I touch search
		Then I should see results
		And click on first result
		Then I should see the "UserSearchResult" screen


	@TA12601
	Scenario: Back to Search screen
		Given I am on the "HashtagSearchResult" screen
		When I touch back button
		Then I should see the "Search" screen


