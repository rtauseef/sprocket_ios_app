Feature:Photo Share
  As a user I want to share my edited photo by mail,Print or Save to Camera Roll


  @reset
  @done
  Scenario: Photo share options
    Given I am on the "Preview" screen
    When I tap "share" button
    Then I should see the "Share" screen


  @reset
  @done
  Scenario:Photo share by mail
    Given I am on the "Share" screen
    When I touch "Mail"
    Then I should see the "Mail" screen


  @reset
  @done
  Scenario:Photo print
    Given I am on the "Share" screen
    When I touch "Print"
    Then I should see the "Page Settings" screen

  @reset
  @done
  Scenario:Save to Camera Roll
    Given I am on the "Share" screen
    When I touch "Save to Camera Roll"
    Then I should see the "Preview" screen

  @reset
  @done
  Scenario:Cancel the Share
    Given I am on the "Share" screen
    When I cancel the share
    Then I should see the "Preview" screen

  @reset
  @done
  Scenario: Verify share functionality
    Given I am on the "CameraRollAlbums" screen
    Then I touch Camera Roll Image
    And I should see the camera roll photos
    When I touch a photos in Camera Roll photos
    Then I should see the "Preview" screen
    And I close the camera pop up
    Then I tap "share" button
    Then I should see the "Share" screen
    Then I should see "Mail" option
    Then I should see "Print" option
    Then I should see "Save to Camera Roll" option


