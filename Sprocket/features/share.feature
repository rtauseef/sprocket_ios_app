Feature:Photo Share
  As a user I want to share my edited photo by mail,Print or Save to Camera Roll


  @reset
  @done
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
  @done
  Scenario:Cancel the Share
    Given I am on the "Share" screen
    When I cancel the share
    Then I should see the "Instagram Preview" screen

  @reset
  @done
  Scenario: Verify share functionality
    Given I am on the "CameraRollAlbums" screen
    Then I touch Camera Roll Image
    And I should see the camera roll photos
    When I touch a photos in Camera Roll photos
    Then I should see the "CameraRoll Preview" screen
    And I close the camera pop up
    Then I tap "Share" button
    Then I should see the "Share" screen
    Then I should see "Print to sprocket" option
    Then I should see "Save to Camera Roll" option


