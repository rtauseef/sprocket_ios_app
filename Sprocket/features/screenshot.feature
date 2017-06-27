Feature: Verify Screenshot feature
  As a user I want to take screenshot of the available screens
 
    @TA18215
    @screenshot
    Scenario Outline: Take screenshots of all the screens
        Given  I am on the "<screen_name_sprocket>" screen
        And I take screenshot of "<screen_name_sprocket>" screen
        Examples:
        |screen_name_sprocket  | 
        |Landing               | 
        |Instagram Landing     |
        |Instagram Signin      |
        |Google Landing        |
        |CameraRoll Albums     |
        |CameraRoll Photo      | 
        |Side Menu             |
        |Instagram Preview     |
        |Google Preview        |
        |CameraRoll Preview    |
        |Edit                  |
        |Share                 |
        |Filter Editor         |
        |Crop Editor           |
        |Frame Editor          |
        |Sticker Editor        |
        |Text Edit             |
        |About                 |
        |Facebook Landing      |
        |Reset Sprocket Printer|
        |Setup Sprocket Printer|
        |Sprocket              |
        |Sticker Option Editor |
        |Survey                |
        |Technical Information |
        |Text Option Editor    |

     @TA18215
     @screenshot
    Scenario: Take screenshots of all the screens
        Given  I am on the "Landing" screen
        Then I zip the "screenshot" folder
