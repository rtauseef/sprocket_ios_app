Feature: Verify Filter-edit screen
  As a user
  I want to verify Filter features.

  
@regression
Scenario Outline: Verify 'Filter' option
    Given I am on the "<social_media_screen_name>" screen
    When I choose "edit" option
    Then I should see the "Edit" screen
    When I choose "filter" option
    Then I should see the "FilterEditor" screen
    When I choose "close" option
    Then I should see the "Edit" screen
    
   
    Examples:
    | social_media_screen_name |
    | Instagram Preview   |
    | CameraRoll Preview |

@done
Scenario Outline: Verify Filter selection option
    Given I am on the "FilterEditor" screen for "<social_media_screen_name>" 
    Then I select "first_filter"
    And I verify the filter is selected
    Then I choose "save" option
    Then I should see the "Edit" screen
    
   
    Examples:
    | social_media_screen_name|
    | Instagram Preview       |
    | CameraRoll Preview  |
    

@regression
Scenario: Verify filer list
    Given I am on the "FilterEditor" screen for "CameraRoll Preview" 
    Then I select "first_filter"
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

    