Feature:Photo Share
  As a user I want to share my edited photo by mail,Print or Save to Camera Roll


  @reset
  @regression
  Scenario: Photo share options
    Given I am on the "Instagram Preview" screen
    When I tap "Share" button
    Then I should see the "Share" screen


  @reset
  @block-Mailoptioncrasheson_simulator
  Scenario:Photo share by mail
    Given I am on the "Share" screen
    When I touch "Mail"
    And I wait for some seconds
    Then I should see the "Mail" screen


  
  @reset
  @done
  Scenario:Save to Camera Roll
    Given I am on the "Share" screen
    When I touch "Save to Camera Roll"
    And I touch Cancel
    Then I should see the "CameraRoll Preview" screen

  @reset
  @regression
  Scenario:Cancel the Share
    Given I am on the "Share" screen
    When I cancel the share
    Then I should see the "Instagram Preview" screen

  @reset
  @TA17012
  Scenario Outline: Verify share functionality
    Given I am on the "<social_media_screen_name>" screen
    Then I tap "Share" button
    Then I should see the "Share" screen
    Then I should see "Print to sprocket" option
    Then I should see "Save to Camera Roll" option
    
Examples:
    | social_media_screen_name        |
    | Instagram Preview  |
  #  | Flickr Preview     |
    | CameraRoll Preview |
    


