@ios8
@printqueue
Feature: Printing without wifi using photos 



    @reset
    Scenario: Navigate to Select Template Screen from Print Queue screen
        Given I have disconnected wifi
        And I am on the "Camera Roll Select Template" screen
        When I touch Share icon
        And I wait for some seconds
        And I touch Print Queue
        Then I should see the "Add Print" screen
        And I verify template name and date displayed
        When I touch "Add to Print Queue"
        Then I should see the "Print Queue" screen
        And I should see the selected template name
        When I touch "Done"
		Then I should see the "Select Template" screen
        And I have connected wifi
        
        
    @reset
    Scenario: Navigate to Select Template Screen from Add Print screen
        Given I have disconnected wifi
        And I am on the "Camera Roll Select Template" screen
        When I touch Share icon
        Then I wait for some seconds
        And I touch Print Queue
        Then I wait for some seconds
        When I touch "Cancel" button
        Then I should see the "Select Template" screen
        And I have connected wifi
        
    @reset
    Scenario: Verify Printqueue count from side menu
        Given I am on the "Select Template" screen
        Then I add "1" job to print queue
        When I touch "Done"
        And I touch the navigation back to Sidemenu
		Then I should see the side menu
		And I verify the Print Queue Count is "1"
        When I touch menu button on navigation bar
        Given I am on the "Select Template" screen
        Then I add "1" job to print queue
        When I touch "Done"
        And I touch the navigation back to Sidemenu
		Then I should see the side menu
		And I verify the Print Queue Count is "2"
        And I have connected wifi
        
    @reset
    Scenario: Verify template name edited on Print Queue screen
        Given I have disconnected wifi
        And I am on the "Camera Roll Select Template" screen
        When I touch Share icon
        And I wait for some seconds
        And I touch Print Queue
        Then I should see the "Add Print" screen
        Then I modify the name
        And I touch "Add to Print Queue"
        And I wait for some seconds
        Then I verify names displayed in Print Queue screen
        When I touch "Done"
        And I touch the navigation back to Sidemenu
        Then I touch "Print Queue"
        Then I verify names displayed in Print Queue screen
        And I have connected wifi
        
    @reset
    Scenario: Verify Printqueue screen navigation to side menu
        Given I am on the "Select Template" screen
        Then I add "2" job to print queue
        When I touch "Done"
		Then I should see the "Select Template" screen
        And I have connected wifi
        When I touch the navigation back to Sidemenu
        Then I touch "Print Queue"
        And I check "Done" button "Enabled"
        And I check "Check Box" button "Unchecked"
        And I check "Select All" button "Enabled"
        And I check "Delete" button "Disabled"
        And I check "Next" button "Disabled"
        When I touch "Done"
        Then I should see the side menu
        
    @reset
    Scenario: Verify job selection in Print Queue
        Given I am on the "Select Template" screen
        Then I add "2" job to print queue
        When I touch "Done"
		Then I should see the "Select Template" screen
        And I have connected wifi
        When I touch the navigation back to Sidemenu
        Then I touch "Print Queue"
        And I wait for some seconds
        And I touch "Select All" button
        And I verify "2" jobs "Selected"
        And I check "Delete" button "Enabled"
        And I check "Next" button "Enabled"
        And I check "Unselect All" button "Enabled"
        
        
    @reset
    Scenario: Verify job un selection from Print Queue
        Given I am on the "Select Template" screen
        Then I add "2" job to print queue
        When I touch "Done"
		Then I should see the "Select Template" screen
        And I have connected wifi
        When I touch the navigation back to Sidemenu
        #Then I should see the side menu
		And I touch "Print Queue"
        And I wait for some seconds
        And I touch "Select All" button
        And I verify "2" jobs "Selected"
        And I touch "Unselect All" button
        And I verify "2" jobs "Unselected"
        
        
    @reset
    Scenario: Verify print queue job deletion
        Given I am on the "Select Template" screen
        Then I add "2" job to print queue
        And I wait for some seconds
        And I touch "Select All" button
        When I touch "Done"
        And I have connected wifi
        When I touch the navigation back to Sidemenu
        And I touch "Print Queue"
        And I wait for some seconds
        And I "Select" a job
        And I check "Unselect All" button "Enabled"
        And I touch "Delete" button
        And I verify warning message displayed
        And I touch "Delete"
        And I check selected job is deleted
        
    @reset
    Scenario: Verify Printqueue buttons
        Given I am on the "Select Template" screen
        Then I add "2" job to print queue
        And I wait for some seconds
        And I touch "Select All" button
        When I touch "Done"
        And I have connected wifi
        When I touch the navigation back to Sidemenu
       	And I touch "Print Queue"
        And I wait for some seconds
        And I verify "2" jobs "UnSelected"
        And I check "Delete" button "Disabled"
        And I check "Next" button "Disabled"
        And I "Select" a job
        And I check "Delete" button "Enabled"
        And I check "Next" button "Enabled"
        
    @reset
    Scenario: Verify Printqueue jobs print
        Given I am on the "Select Template" screen
        Then I add "2" job to print queue
        And I wait for some seconds
        And I touch "Select All" button
        When I touch "Done"
        And I have connected wifi
        And I wait for some seconds
        When I touch the navigation back to Sidemenu
        And I touch "Print Queue"
        And I wait for some seconds
        And I touch "Select All" button
        Then I touch "Next"
        Then I should see the "Page Settings" screen
        Then I run print simulator
        Then I click Printer control to see printers list
        And I scroll down until "Simulated InkJet" is visible in the list
        Then I touch "Print"
		Then I wait for some seconds
       
   
  
    @reset
    Scenario: Navigate to Print Queue
        Given I am on the "Select Template" screen
        Then I add "1" job to print queue
        And I wait for some seconds
        When I touch "Done"
        And I have connected wifi
		Then I should see the "Select Template" screen
		When I touch the navigation back to Sidemenu
		Then I should see the side menu
          
  @reset
  Scenario: Verify name edited on Print Queue screen
    Given I am on the "Select Template" screen
    Then I add "1" job to print queue
    Then I verify names displayed in Print Queue screen
    And I touch "Delete" button
    And I verify warning message displayed
    And I touch "Delete"
	
  @reset
  Scenario: Verify multiple item deletion from print queue
    Given I am on the "Select Template" screen
    Then I add "2" job to print queue
    Then I verify names displayed in Print Queue screen
    And I touch "Select All" button
    And I touch "Delete" button
    And I verify warning message displayed
    And I touch "Delete"
    
  @reset
  Scenario: Verify multiple item deletion from print queue
    Given I am on the "Select Template" screen
    Then I add "3" job to print queue
    Then I verify names displayed in Print Queue screen
    And I wait for some seconds
    And I "Select" a job
    And I touch "Delete" button
    And I verify warning message displayed
    And I touch "Delete"
    And I wait for some seconds
    And I wait for some seconds
    And I check selected job name is deleted