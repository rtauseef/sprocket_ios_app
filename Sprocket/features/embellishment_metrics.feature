Feature: Verify embellishment metrics
    As a user
    I want to Check and Verify embellishment metrics for different options


    @done
    @regression
    Scenario: Verify embellishment metrics for stickers
    Given I am on the "StickerEditor" screen for "CameraRoll Preview"
    And I select "Decorative Category" tab
    Then I select "sticker_3" sticker
    Then I touch "Add"  
    And I select "Summer Category" tab
    Then I select "sticker_7" sticker
    Then I touch "Add"  
    And I select "Nature Category" tab
    Then I select "sticker_0" sticker
    Then I touch "Delete"
    Then I should see the "Edit" screen
    Then I choose "sticker" option
    And I select "Face Category" tab
    Then I select "sticker_11" sticker
    #Then I should see the "StickerOptionEditor" screen
    Then I touch "Add"  
    And I select "Decorative Category" tab
    Then I select "sticker_9" sticker
    Then I touch "Delete"
    Then I should see the "Edit" screen
    And I should see the photo with the "sticker_3" sticker from "Decorative Category" tab
    And I should see the photo with the "sticker_7" sticker from "Summer Category" tab
    And I should see the photo with the "sticker_11" sticker from "Face Category" tab
    Then I choose "check" option
    Then I should see the "CameraRoll Preview" screen
    When I choose "download" option
	Then I wait for some seconds
    Then Fetch metrics details
    Then I Fetch embellishment metrics details
    And I verify the "embellishment" metrics length is "3"
    Then I verify "name" of "embellishment metrics-1" is "sticker_3"
    Then I verify "category" of "embellishment metrics-1" is "Sticker"
    Then I verify "name" of "embellishment metrics-2" is "sticker_7"
    Then I verify "category" of "embellishment metrics-2" is "Sticker"
    Then I verify "name" of "embellishment metrics-3" is "sticker_11"
    Then I verify "category" of "embellishment metrics-3" is "Sticker"


    @done
    @regression
    Scenario: Verify embellishment metrics for autofix,frame and sticker
    Given I am on the "StickerEditor" screen for "CameraRoll Preview"
    And I select "Decorative Category" tab
    Then I select "sticker_0" sticker
    And I should see the photo with the "sticker_0" sticker from "Decorative Category" tab
    Then I am on the "StickerOptionEditor" screen
    Then I choose "save" option
    Then I should see the "Edit" screen
    And I choose "frame" option
    Then I select "frame_1" frame
    Then I should see the photo with the "frame_1" frame
    Then I am on the "Frame Editor" screen
    Then I choose "save" option
    Then I am on the "Edit" screen
    Then I select "autofix"
    Then I choose "check" option
    Then I should see the "CameraRoll Preview" screen
    When I choose "download" option
    Then I wait for some seconds
    Then Fetch metrics details
    Then I Fetch embellishment metrics details
    And I verify the "embellishment" metrics length is "3"
    Then I verify "name" of "embellishment metrics-1" is "sticker_0"
    Then I verify "category" of "embellishment metrics-1" is "Sticker"
    Then I verify "name" of "embellishment metrics-2" is "frame_0"
    Then I verify "category" of "embellishment metrics-2" is "Frame"
    Then I verify "name" of "embellishment metrics-3" is "Auto-fix"
    Then I verify "category" of "embellishment metrics-3" is "Edit"



    @done
    Scenario: Verify embellishment metrics for random sticker selection
    Given I am on the "StickerEditor" screen for "CameraRoll Preview"
    Then I select a sticker from "Decorative Category"
    Then I should see the "StickerOptionEditor" screen
    And I should see the photo with the sticker from "Decorative Category" tab
    Then I choose "save" option
    Then I should see the "Edit" screen
    Then I choose "check" option    
    Then I should see the "CameraRoll Preview" screen
    When I choose "download" option
    Then I wait for some seconds
    Then Fetch metrics details
    Then I Fetch embellishment metrics details
    And I verify the "embellishment" metrics length is "1"
    Then I verify "name" of "embellishment metrics-1"
    Then I verify "category" of "embellishment metrics-1" is "Sticker"


  
        
        