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
    | CameraRoll Preview  |
    
@reset
@regression
Scenario: Verify filer list
    Given I am on the "FilterEditor" screen for "CameraRoll Preview" 
    Then I select "Filter"
    Then I should see the following "filters" in the screen:
    | None      |
    | AD1920    |
    | Candy     |
    | Lomo      |
    | Litho     |
    | Quozi     |
    | SepiaHigh |
    | Sunset    |
    | Twilight  |
    | Breeze    |
    | Blues     |
    | Dynamic   |
    | Orchid    |
    | Pale      |
    | 80s       | 
    | Pro400    |
    | Steel     |
    | Creamy    |

    