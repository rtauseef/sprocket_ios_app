Feature:Print Page Settings
  As a user I want to select paper size, number of copies and photo color mode


  @reset
  @regression
  Scenario: Verify Printer Options
		Given I am on the "Page Settings" screen
		When I click print label
		Then I can see printer list


  @ios8
  @regression
	Scenario: Back to Select Template screen
		Given I am on the "Page Settings" screen
		When I touch the "Cancel" button
		Then I should see the "Select Template" screen



  @reset
  @done
  Scenario: Verify available sizes
    Given I am on the "Page Settings" screen
    And I scroll screen "down"
    When I touch "Paper Size" option
    Then I should see the following:
    

      | 4 x 5 	    |
      | 4 x 6       |
      | 5 x 7       |
      | 8.5 x 11    |


  @regression
    	Scenario: Verify Print Instructions link
		Given I am on the "Page Settings" screen
		And I scroll screen "down"
		When I touch "Print Instructions" option
		Then I should see the "Print Instructions" screen

  @regression
	Scenario: Verify Buy sticker pack link
		Given I am on the "Page Settings" screen
        And I scroll screen "down"
		When I touch "Buy sticker pack" option
        Given  I am on the safari screen
		Then I should see the HP Store page

  @reset
  @ios8
  @done
	Scenario: Verify Black & White mode
		Given I am on the "Page Settings" screen
		And I scroll screen "down"
		When I touch switch
		Then switch should turn ON


  @reset
  @regression
  Scenario: Verify Paper type options
	   Given I am on the "Paper Size" screen
	   And  I selected the paper size "8.5 x 11"
	   And I should see the paper type options
	   Then I should see the following:

		 | Plain Paper |
		 | Photo Paper |

  @ios8
  @reset
  @regression
  Scenario: Verify Increase number of copies
		Given I am on the "Page Settings" screen
		And I scroll screen "down"
		And the number of copies is 1
        When I touch "Increment" and check number of copies is 2
	    When I touch "Decrement" and check number of copies is 1


  @ios8
  @reset
	@regression
	Scenario Outline:Select number of copies on different templates
		Given I am on the "Select Template" screen
		And I click on screen if coach marks are present
		When I touch the "<template_name>" template
		And I touch Share icon
		Then I am on the "Page Settings" screen
		And I scroll screen "down"
		And the number of copies is 1
		When I touch "Increment" and check number of copies is 2
		When I touch "Decrement" and check number of copies is 1


			Examples:
			| template_name  |
			| Hemingway      |
			| Kerouac        |
			| Asimov         |
			| Lovecraft      |
			| Wallace        |
			| Ariel 		 |
			| Sofia    		 |
			| Jack           |
			| Steinbeck      |
			| Dickens        |
			| Clean          |



    @ios8
	@reset
	@regression
	Scenario Outline: Select number of copies on different paper size
		Given I am on the "Paper Size" screen
		When I touch "<size_option>"
		Then I should see the "Page Settings" screen
		And I scroll screen "down"
		And the number of copies is 1
		When I touch "Increment" and check number of copies is 2
		When I touch "Decrement" and check number of copies is 1

	Examples:
		| size_option |
		| 4 x 5 	  |
		| 4 x 6       |
		| 5 x 7       |
		| 8.5 x 11    |
