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
    And I should see the modal screen title
    And I should see the modal screen content
    And I should see the button "OK"
    And I should see the button "Settings"
    And I tap the "OK" button
    Then I should not see the modal screen
    Then I should see the "Device" screen
    And I should see the message to pair the device with the bluetooth printer
    
@reset
@TA14290
Scenario: Printer Paired to device but not connected
    Given I am on the "Preview" screen
    When I tap "Print" button
    Then I should see the modal screen title
    And I should see the modal screen content
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
    
@reset
@TA14384
Scenario: Device paired with two printers
    Given  I am on the "Landing" screen
    When I touch menu button on navigation bar
	Then I should see the side menu
    Then I touch "Devices"
    Then I should see the "Device" screen
    And I should see the list of two printers conneceted
    Then I tap the Printer
    And I check the screen title with the corresponding printer name
    And I check "Errors" field displays its value
    And I check "Battery Status" field displays its value
    And I check "Auto Off" field displays its value
    And I check "Mac Address" field displays its value
    And I check "Firmware Version" field displays its value
    And I check "Hardware Version" field displays its value
    
   
    
@reset
@TA14384
Scenario: Verify select Printer screen with two printers paired
    Given I am on the "Preview" screen
    When I tap "Print" button
    Then I should see the "Select Printer" screen
    And I should see the list of two printers conneceted
    Then I tap the Printer
    Then I should see the "Preview" screen
    Then I tap "Print" button
    Then I should see the "Select Printer" screen
    Then I verify the selected printer is listed in Recent Printer field
    And I verify the second printer is listed in Other Printers field
