Feature: Check Paper size and Paper type
    As a user
    I want to Check and Verify Paper size and Paper type

    @reset
	@verifysize
	Scenario Outline: verify paper size with Wireshark for iOS
		Given I am on the "Page Settings" screen
		Then I run the tshark to monitor the print job
		And I should see the paper size options
		Then I selected the paper size "<size_option>"
		#Then I should see printer details
        Then I wait for some seconds
        And I scroll down until "Simulated InkJet" is visible in the list
        Then I choose print button
		Then I wait for some seconds
		Then I stop the wireshark execution
		And I am verifying the "<size_option>" paper size
		And I am verifying the border borderless
		Then I wait for some seconds

	Examples:
		| size_option          |
		| 4 x 5  |
		| 4 x 6       |
		| 5 x 7       |

  @reset
  @verifytype
	Scenario Outline: verify paper size and Paper type for "8.5 x 11" with Wireshark for iOS
		Given I am on the "Page Settings" screen
		Then I run the tshark to monitor the print job
		And I should see the paper size options
		Then I selected the paper size "8.5 x 11"
		And I should see the paper type options
		Then I selected the paper type "<type_option>"
		#Then I should see printer details
        Then I wait for some seconds
        And I scroll down until "Simulated InkJet" is visible in the list
        Then I choose print button
		Then I wait for some seconds
		Then I stop the wireshark execution
		And I am verifying the "8.5 x 11" paper size
		Then verifying the paper type "<type_option>"
		Then I wait for some seconds

	Examples:
		| type_option |
		| Plain Paper |
		| Photo Paper |

	@reset
	@verifyborder
	Scenario Outline: Verify "8.5 x 11" Plain Paper print have border with Wireshark for iOS
		Given I am on the "Page Settings" screen
		Then I run the tshark to monitor the print job
		And I should see the paper size options
		Then I selected the paper size "8.5 x 11"
		And I should see the paper type options
		Then I selected the paper type "<type_option>"
		#Then I should see printer details
        Then I wait for some seconds
        And I scroll down until "Simulated InkJet" is visible in the list
        Then I choose print button
		Then I wait for some seconds
		Then I stop the wireshark execution
		And I am verifying the "8.5 x 11" paper size
		Then verifying the paper type "<type_option>"
		And I am verifying the border
		Then I wait for some seconds

	Examples:
		| type_option |
		| Plain Paper |
