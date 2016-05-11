Feature: Access Camera roll photos and verify photos


    @reset
    @smoke
    @done
    Scenario: Verify listView and GridView in Camera Roll Photos
        Given I am on the "CameraRollAlbums" screen
        Then I touch Camera Roll Image
        And I should see the camera roll photos
        Then I should see the photos in a grid view
        When I touch list mode button
        Then I should see the photos in list view
        When I touch grid mode button
        When I touch a photos in Camera Roll photos
        Then I should see the "Select Template" screen
		
		

        
       
    