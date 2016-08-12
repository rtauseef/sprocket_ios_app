Feature: Verify Filter-edit screen
  As a user
  I want to verify Filter features.

  
@reset
@TA14497
Scenario Outline: Verify 'Filter' option
    Given I am on the "<screen_name>" screen
    When I tap "Edit" button
    Then I should see the "Edit" screen
    When I tap "Filter" button
    Then I should see the "FilterEditor" screen
    Then I tap "Close" mark
    Then I should see the "Edit" screen
    
   
    Examples:
    | screen_name        |
    | Preview            |
    | Flickr Preview     |
    | CameraRoll Preview |

@reset
@TA14497
Scenario Outline: Verify Filter selection option
    Given I am on the "FilterEditor" screen for "screen_name" 
    Then I select "Filter"
    And I verify the filter is selected
    Then I tap "Save" mark
    Then I should see the "Edit" screen
    
   
    Examples:
    | screen_name         |
    | Preview            |
    | Flickr Preview     |
    | CameraRoll Preview  |

    