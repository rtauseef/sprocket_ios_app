Feature: Signin with facebook credentials and verify features 
  
 @reset
@fbtest
  Scenario: Navigate to safari from app
    Given  I am on the "Welcome" screen
    Then I touch the next page control
    Then I wait for sometime
    Then I should navigate to facebook screen
    Then I touch "Sign in" button
   Then I wait for sometime
    

    
    @fbtest
    Scenario: Login to facebook from safari
		Given  I am on the safari screen
		And I fill the form with valid credentials for facebook
		Then I wait for sometime
        Then I click ok in confirm dialog
        

@fbtest
  Scenario: facebook already signed in
    Given  I am on the "Welcome" screen
    Then I touch the next page control
    Then I wait for sometime
    Then I should navigate to facebook screen
    Then I wait for sometime
    Then I should see the Facebook Albums screen



  @fbtest
  Scenario Outline: Verify date in all applicable templates of a Facebook photo.
    Given I am on the "Facebook Select Template" screen
    And I click on screen if coach marks are present
    When I touch the "<template_name>" template
    Then I should see the date on photo
    
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

  @fbtest
  Scenario Outline: Verify location in all applicable templates of a Facebook photo.
    Given I am on the "Facebook Select Template" screen
    And I click on screen if coach marks are present
    When I touch the "<template_name>" template
    Then I should see the location on photo
    
  Examples:
    | template_name |
    | Kerouac       |
    | Asimov        |
    | Wallace       |
    | Dickens       |

  @fbtest
  Scenario Outline: Verify like and comment in all applicable templates of a Facebook photo.
    Given I am on the "Facebook Select Template" screen
    And I click on screen if coach marks are present
    When I touch the "<template_name>" template
    Then I should see like and comment on photo
    
  Examples:
    | template_name |
    | Asimov        |
    | Lovecraft     |

  
  @fbtest
  Scenario Outline: Verify template change for Facebook
    Given I am on the "Facebook Select Template" screen
    And I click on screen if coach marks are present
    When I touch the "<template_name>" template
    Then the template "<template_name>" should be selected


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
    | Steinbeck     |
    | Dickens       |
    | Clean         |


  @fbtest
  Scenario Outline: facebook already signed in and print template
    Given  I am on the "Facebook Select Template" screen
    And I click on screen if coach marks are present
    When I touch the "<template_name>" template
    Then the template "<template_name>" should be selected
    When I touch Share icon
    And I touch "Print"
    Then I run print simulator
    And I scroll screen "down"
    And I should see the paper size options
    Then I selected the paper size "4 x 6"
    And I scroll down until "Simulated Laser" is visible in the list
    Then I wait for some seconds
    Then I choose print button
    Then I wait for some seconds
    And I delete printer simulater generated files


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
    | Steinbeck     |
    | Dickens       |
    | Clean         |
    
    
    