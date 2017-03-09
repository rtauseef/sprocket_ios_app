Feature: Verify screen navigation
  As a user I want to check default screens and other screen navigation




 @reset
 @done
 @smoke
Scenario: Verify camera roll navigation
	Given I am on the "Landing" screen
	And I tap "CameraRoll"
	And I touch the Camera Roll button
	When I touch Authorize
	Then I should see the "CameraRoll Photo" screen
	Then I touch "arrowDown"
	Then I should see the camera roll albums
	Then I touch Camera Roll Image
	And I should see the camera roll photos
	When I touch a photos in Camera Roll photos
	Then I should see the "CameraRoll Preview" screen
@reset
@TA17012
Scenario: Verify Instagram navigation   
    Given I am on the "Landing" screen
    Then I should see "Instagram" logo
    And I click on the "Instagram" logo
    Then I should see the "Instagram Landing" screen
    And I click on the "Sign in" button
    Then I should see the "Instagram Signin" screen
    And I enter valid credentials
    And I touch login button
    Then I should see the "Instagram Photos" screen
    When I touch second photo
    Then I should see the "Instagram Preview" screen
    
    
@reset
@TA17012
Scenario: Verify Flickr navigation 
    Given I am on the "Landing" screen
    Then I should see "Flickr" logo
    And I click on the "Flickr" logo
    Then I should see the "Flickr Landing" screen
    And I click on the "Sign in" button
    Then I should see the "Flickr Signin" screen
    And I enter valid credentials
    And I touch login button
    Then I should see the "Flickr Photo" screen
    When I touch second photo
    Then I should see the "Flickr Preview" screen
    

@reset
@TA17012
Scenario: Verify Edit screen navigation    
    Given I am on the "CameraRoll Preview" screen
    Then I tap "Edit" button
    Then I wait for some seconds
    Then I tap "Check" mark
    Then I should see the "CameraRoll Preview" screen
    And I tap "Edit" button
    Then I wait for some seconds
    Then I tap "Close" mark
    Then I should see the "CameraRoll Preview" screen
    
@reset
@TA17012
Scenario: Verify Filter screen navigation  
    Given I am on the "CameraRoll Preview" screen
    Then I tap "Edit" button
    Then I should see the "Edit" screen
    When I tap "Filter" button
    Then I should see the "FilterEditor" screen
    Then I select "Filter"
    And I verify the filter is selected
    Then I tap "Save" mark
    Then I should see the "Edit" screen
    
@reset
@TA17012
Scenario: Verify crop screen navigation  
    Given I am on the "CameraRoll Preview" screen
    Then I tap "Edit" button
    Then I am on the "Edit" screen
    Then I tap "Crop" button
    Then I should see the "Crop Editor" screen
    And I should see "2:3" button
    And I should see "3:2" button
    And I select "3:2"
    Then I tap "Save" mark
    Then I should see the "Edit" screen
    And I should see the "cropped" image
    
@reset
@TA17012
Scenario: Verify frame screen navigation
    Given I am on the "CameraRoll Preview" screen
    Then I tap "Edit" button
    Then I should see the "Edit" screen
    Then I tap "Frame" button
    Then I should see the "Frame Editor" screen
    Then I select "Turquoise Frame" frame
    Then I tap "Save" mark
    Then I should see the "Edit" screen
    And I should see the photo with the "Turquoise Frame" frame
    

@reset
@TA17012
Scenario: Verify sticker screen navigation
    Given I am on the "CameraRoll Preview" screen
    Then I tap "Edit" button
    Then I should see the "Edit" screen
    Then I tap "Sticker" button
    Then I should see the "Sticker Editor" screen
    Then I select "sticker_0" sticker
    Then I should see the photo with the "sticker_0" sticker
    Then I tap "Save" mark
    Then I should see the "Edit" screen
    Then I should see the photo with the "sticker_0" sticker
    
    
@reset
@TA17012
Scenario: Verify text screen navigation
    Given I am on the "CameraRoll Preview" screen
    Then I tap "Edit" button
    Then I should see the "Edit" screen
    Then I tap "Text" button
    Then I should see the "TextEdit" screen
    And I enter unique text
    Then I tap "Add text" mark
    And I tap "Save" mark
    Then I should see the "Edit" screen
    And I should see the photo with the "text"
