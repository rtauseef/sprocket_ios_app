Feature: Verify no printer added modal
  As a user
  I want to verify no printer added modal.

  @reset
  @TA14290
  Scenario: No printer paired
    Given  I am on the "Landing" screen
    When I touch menu button on navigation bar
	Then I should see the side menu
    Then I touch "Devices"
    Then I should see the message to pair the device with the bluetooth printer
    And I should see the modal screen with the message to connect the printer
    And I should see the modal screen title
    And I should see the modal screen content
    And I should see the button "OK"
    And I should see the button "Settings"
    And I tap the "OK" button
    Then I should not see the modal screen
    
@reset
@TA14290
Scenario: Printer Paired to device but not connected
    Given I am on the "Preview" screen
    When I tap "Print" button
    Then I should see the modal screen title
    And I should see the modal screen content
    And I should see the modal screen with the message to connect the printer
    And I should see the modal screen title
    And I should see the modal screen content
    And I should see the button "OK"
    And I should see the button "Settings"
    And I tap the "OK" button
    Then I should not see the modal screen
    
@reset
@TA14290
Scenario: Printer Paired to device and connected
    Given I am on the "Preview" screen
    When I tap "Print" button
    Then I should see the "Preview" screen