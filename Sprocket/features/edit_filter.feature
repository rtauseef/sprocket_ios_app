Feature: Verify Filter-edit screen
  As a user
  I want to verify Filter features.

  
@reset
@regression
Scenario Outline: Verify 'Filter' option
    Given I am on the "<social_media_screen_name>" screen
    When I tap "Edit" button
    Then I should see the "Edit" screen
    When I tap "Filter" button
    Then I should see the "FilterEditor" screen
    Then I tap "Close" mark
    Then I should see the "Edit" screen
    
   
    Examples:
    | social_media_screen_name |
    | Instagram Preview   |
   # | Flickr Preview     |
    | CameraRoll Preview |

@reset
@done
Scenario Outline: Verify Filter selection option
    Given I am on the "FilterEditor" screen for "<social_media_screen_name>" 
    Then I select "Filter"
    And I verify the filter is selected
    Then I tap "Save" mark
    Then I should see the "Edit" screen
    
   
    Examples:
    | social_media_screen_name|
    | Instagram Preview       |
   # | Flickr Preview     |
    | CameraRoll Preview  |

    