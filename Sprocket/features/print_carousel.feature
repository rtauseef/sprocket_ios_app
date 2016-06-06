Feature: Verify print carousel in page settings screen
    
 @reset
  @ios8
  @TA12757
  Scenario: Verify carousal view for print queue job print in Page Settings screen
  Given I have disconnected wifi
  And I am on the "Camera Roll Select Template" screen
  When I touch Share icon
  And I wait for some seconds
  And I touch Print Queue
  Then I should see the "Add Print" screen
  And I modify the name
  When I touch "Increment" and check number of copies is 2
  And I touch "Add 2 Pages"
  And I wait for some seconds
  When I touch "Done"
  Then I add "1" job to print queue
  And I wait for some seconds
  And I touch "Select All" button
  Then I touch "Next"
  Then I should see the "Page Settings" screen
  Then I verify print job details
    
