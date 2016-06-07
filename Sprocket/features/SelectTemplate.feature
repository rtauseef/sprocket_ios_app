Feature: Select different templates
  As a signed in user
  I should be able to select different templates for my pictures


	@reset
	@smoke
	Scenario: Navigate to Select Template screen
		Given I am on the "Home" screen
		When I touch second photo
		Then I should see the "Select Template" screen
		And I click on screen if coach marks are present
		Then I should see the image with "Hemingway" template applied

  @reset
  @regression
	Scenario: Back to list of photos
		Given I am on the "Select Template" screen
		When I go back
		Then I should see the "Home" screen

  @reset
  @regression
	Scenario: Navigate to Select Template from My feed
		Given I am on the "Home" screen
		And I touch "My Feed"
		When I touch second photo
		Then I should see the "Select Template" screen

  @reset
	@done
	@smoke
	Scenario: Verify available templates list
		Given I am on the "Select Template" screen
		And I click on screen if coach marks are present
		Then I should see the following options:
		  | Hemingway      |
          | Kerouac        |
          | Asimov         |
          | Lovecraft      |
          | Wallace        |
          | Ariel          |
          | Sofia          |
          | Jack           |
          | Steinbeck      |
          | Dickens        |
          | Clean          |

  @reset
  @regression
  Scenario Outline: Verify template change for instagram
    Given I am on the "Select Template" screen
    And I click on screen if coach marks are present
    When I touch the "<template_name>" template
    Then the template "<template_name>" should be selected


		  Examples:
            | template_name  |
            | Hemingway      |
            | Kerouac        |
            | Asimov         |
            | Lovecraft      |
            | Wallace        |
            | Ariel          |
            | Sofia          |
            | Jack           |
            | Steinbeck      |
            | Dickens        |
            | Clean          |


  @reset
  @done
  Scenario: Last selected template is retained in 'Select Template' screen of newly selected photo
    Given I am on the "Select Template" screen
    And I click on screen if coach marks are present
    Then I should see the image with "Hemingway" template applied
    When I touch the "Asimov" template
    Then I should see the image with new template applied
    When I go back
    Then I should see the "Home" screen
    When  I am on the "Select Template" screen
    And I click on screen if coach marks are present
    Then I should see the image with "Asimov" template applied


  @reset
  @done
  Scenario: Coach mark for first time user
		Given I am on the "Select Template" screen
		Then I should see coach marks

  @reset
  @regression
  Scenario Outline: Verify template change for Flickr
    Given I am on the "Flickr Select Template" screen
    And I click on screen if coach marks are present
    When I touch the "<template_name>" template
    Then the template "<template_name>" should be selected

  Examples:
    | template_name  |
    | Hemingway      |
    | Kerouac        |
    | Asimov         |
    | Lovecraft      |
    | Wallace        |
    | Ariel          |
    | Sofia          |
    | Jack           |
    | Steinbeck      |
    | Dickens        |
    | Clean          |

  @reset
  @regression
  Scenario Outline: Verify template change for Camera Roll
    Given I am on the "CameraRoll Select Template" screen
    And I click on screen if coach marks are present
    When I touch the "<template_name>" template
    Then the template "<template_name>" should be selected


  Examples:
    | template_name  |
    | Hemingway      |
    | Kerouac        |
    | Asimov         |
    | Lovecraft      |
    | Wallace        |
    | Ariel          |
    | Sofia          |
    | Jack           |
    | Steinbeck      |
    | Dickens        |
    | Clean          |


  @reset
  @regression
  Scenario Outline: Verify username in all applicable templates of a Flickr photo.
    Given I am on the "Flickr Select Template" screen
    And I click on screen if coach marks are present
    When I touch the "<template_name>" template
    Then I should see the username on photo
    
  Examples:
    | template_name |
    | Hemingway     |
    | Kerouac       |
    | Asimov        |
    | Lovecraft     |
    | Wallace       |
    | Ariel         |
    | Steinbeck     |

  @reset
  @regression
  Scenario Outline: Verify username in all applicable templates of an Instagram photo.
    Given I am on the "Select Template" screen
    And I click on screen if coach marks are present
    When I touch the "<template_name>" template
    Then I should see the username on photo
    
  Examples:
    | template_name |
    | Hemingway     |
    | Kerouac       |
    | Asimov        |
    | Lovecraft     |
    | Wallace       |
    | Ariel         |
    | Steinbeck     |

  @reset
  @regression
  Scenario Outline: Verify date and description in all applicable templates of a Flickr photo.
    Given I am on the "Flickr Select Template" screen
    And I click on screen if coach marks are present
    When I touch the "<template_name>" template
    Then I should see the date on photo
    Then I should see the description on photo
    
  Examples:
    | template_name |
    | Hemingway     |
    | Kerouac       |
    | Asimov        |
    | Lovecraft     |
    | Wallace       |
    | Ariel         |
    | Sofia         |
    | Jack          |
    | Dickens       |

  @reset
  @regression
  Scenario Outline: Verify date and description in all applicable templates of an Instagram photo.
    Given I am on the "Select Template" screen
    And I click on screen if coach marks are present
    When I touch the "<template_name>" template
    Then I should see the date on photo
    Then I should see the description on photo
    
  Examples:
    | template_name |
    | Hemingway     |
    | Kerouac       |
    | Asimov        |
    | Lovecraft     |
    | Wallace       |
    | Ariel         |
    | Sofia         |
    | Jack          |
    | Dickens       |

  @reset
  @regression
  Scenario Outline: Verify location in all applicable templates of a Flickr photo.
    Given I am on the "Flickr Select Template" screen
    And I click on screen if coach marks are present
    When I touch the "<template_name>" template
    Then I should see the location on photo
    
  Examples:
    | template_name |
    | Kerouac       |
    | Asimov        |
    | Wallace       |
    | Dickens       |

  @reset
  @regression
  Scenario Outline: Verify location in all applicable templates of an Instagram photo.
    Given I am on the "Select Template" screen
    And I click on screen if coach marks are present
    When I touch the "<template_name>" template
    Then I should see the location on photo
    
  Examples:
    | template_name |
    | Kerouac       |
    | Asimov        |
    | Wallace       |
    | Dickens       |

  @reset
  @regression
  Scenario Outline: Verify like and comment in all applicable templates of a Flickr photo.
    Given I am on the "Flickr Select Template" screen
    And I click on screen if coach marks are present
    When I touch the "<template_name>" template
    Then I should see like and comment on photo
    
  Examples:
    | template_name |
    | Asimov        |
    | Lovecraft     |

  @reset
  @regression
  Scenario Outline: Verify like and comment in all applicable templates of an Instagram photo.
    Given I am on the "Select Template" screen
    And I click on screen if coach marks are present
    When I touch the "<template_name>" template
    Then I should see like and comment on photo
    
  Examples:
    | template_name |
    | Asimov        |
    | Lovecraft     |


  @reset
  @done
  Scenario: Verify date description, location, like and comment of an Instagram photo.
    Given I am on the "Select Template" screen
    And I click on screen if coach marks are present
    When I touch the "Asimov" template
    Then I should see the image with "Asimov" template applied
    Then I should see like and comment on photo
    Then I should see the location on photo
    Then I should see the date on photo
    Then I should see the description on photo
    Then I should see the username on photo

  @reset
  @done
  Scenario: Verify date description, location, like and comment of a Flickr photo.
    Given I am on the "Flickr Select Template" screen
    And I click on screen if coach marks are present
    When I touch the "Lovecraft" template
    Then I should see the image with "Lovecraft" template applied
    Then I should see like and comment on photo
    Then I should see the location on photo
    Then I should see the date on photo
    Then I should see the description on photo
    Then I should see the username on photo
