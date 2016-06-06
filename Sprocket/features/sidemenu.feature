Feature: Side Menu
  In order to navigate through the app
  As a user
  I want to open and close the side menu


  @regression
	Scenario: Open side menu
		Given I am on the "Home" screen
		When I touch menu button on navigation bar
		Then I should see the side menu


	@done
	@smoke
	Scenario: Close side menu
		Given I am on the "Home" screen
		When I touch menu button on navigation bar,twice
		Then I should not see the side menu



  @regression
	Scenario: Open Learn about Mobile Printing screen from Side menu
		Given I am on the "Home" screen
		And  I touch menu button on navigation bar
		When I touch "Learn about Mobile Printing"
		Then I should see the "Print Instructions" screen    
		When I touch "Done"
		Then I should see the side menu


	@done
	@regression
	Scenario: Open About screen  from Side menu
		Given I am on the "Home" screen
		And  I touch menu button on navigation bar
		When I touch "About"
		Then I should see the "About" screen    
		When I touch "Done"
		Then I should see the side menu



  @regression
	Scenario: Open Feedback screen from Side menu
		Given I am on the "Home" screen
		And  I touch menu button on navigation bar
		When I touch "Send Feedback"
		Then I should see the "Feedback" screen

  @regression
	Scenario: Open Take our Survey from Side menu
		Given I am on the "Home" screen
		And I touch menu button on navigation bar
		When I touch "Take our Survey"
        Then I wait for some time
		Then I should see the "Survey" screen
		When I touch "Done"
		Then I should see the side menu

  @regression
	Scenario: Open Privacy Statement from Side menu
		Given I am on the "Home" screen
		And  I touch menu button on navigation bar
		When I touch "Privacy Statement"
        Then I wait for some time
		Then I should see the "Privacy Statement" screen
		When I touch "Done"
		Then I should see the side menu

    @reset
	@done
	Scenario: Instagram Sign Out from Side menu
		Given I am on the "Home" screen
		And  I touch menu button on navigation bar
		When I touch Instagram "Sign Out" button
	    And I click Sign Out button on popup
		Then I should see Instagram "Sign In" button
        
    @reset
	@done
	Scenario: Flickr Sign Out from Side menu
		Given I am on the "FlickrAlbum" screen
		And  I touch menu button on navigation bar
		When I touch Flickr "Sign Out" button
		And I click Sign Out button on popup
		Then I should see Flickr "Sign In" button

  @reset
	@done
   	Scenario: Profile pic on side menu
		Given I am on the "Landing" screen
		And  I touch menu button on navigation bar
		And  I touch Instagram "Sign In" button
	    And I fill the form with valid Instagram credentials
        When I touch Instagram Log in button
		Then I should see the user's profile pic

