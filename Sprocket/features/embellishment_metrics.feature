Feature: Verify embellishment metrics
    As a user
    I want to Check and Verify embellishment metrics for different options

    
    @111
    Scenario: Verify embellishment metrics for stickers
    Given I am on the "StickerEditor" screen for "CameraRoll Preview"
    And I select "Graduation Category" tab
    Then I select "sticker_3" sticker
    Then I touch "Add"  
    And I select "Summer Category" tab
    Then I select "sticker_7" sticker
    Then I touch "Add"  
    And I select "Cannes Category" tab
    Then I select "sticker_0" sticker
    Then I touch "Delete"
    Then I should see the "Edit" screen
    Then I tap "Sticker" button
    And I select "Face Category" tab
    Then I select "sticker_11" sticker
    #Then I should see the "StickerOptionEditor" screen
    Then I touch "Add"  
    And I select "Decorative Category" tab
    Then I select "sticker_9" sticker
    Then I touch "Delete"
    Then I should see the "Edit" screen
    And I should see the photo with the "sticker_3" sticker from "Graduation Category" tab
    And I should see the photo with the "sticker_7" sticker from "Summer Category" tab
    And I should see the photo with the "sticker_11" sticker from "Face Category" tab
    Then I tap "Check" mark
    And I wait for some seconds
    And I wait for some seconds
    Then I am on the "CameraRoll Preview" screen
    When I tap "Download" button
		Then I wait for some seconds
    Then Fetch metrics details
    Then I Fetch embellishment metrics details
    And I verify the "embellishment" metrics length is "3"
    And I verify the sticker names
    And I verify the category is "Sticker"

        
    @11
    Scenario: Verify embellishment metrics for autofix
    Given I am on the "StickerEditor" screen for "CameraRoll Preview"
    And I select "Graduation Category" tab
    Then I select "sticker_0" sticker
    Then I am on the "StickerOptionEditor" screen
    Then I tap "Save" mark
    Then I should see the "Edit" screen
    And I tap "Frame" button
    Then I select "frame_0" frame
    Then I should see the photo in the "Frame Editor" screen with the "frame_0" frame
    Then I am on the "Frame Editor" screen
    Then I tap "Save" mark
    Then I am on the "Edit" screen
    Then I select "AutoFix"
    Then I wait for some seconds
    Then Fetch metrics details
    Then I Fetch embellishment metrics details
    And I verify the "embellishment" metrics length is "3"
        
        