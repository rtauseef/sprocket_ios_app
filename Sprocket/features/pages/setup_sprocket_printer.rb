

require 'calabash-cucumber/ibase'

class SetupSprocketPrinterScreen < Calabash::IBase

  def trait
      title
  end

  def title
     # "view {text CONTAINS 'Technical Information'}"
      "navigationBar marked:'Setup Sprocket Printer'"
  end
    
    def back
       "view marked:'Back'"
    end
    
    
  def navigate
    unless current_page?
      landing_screen = go_to(LandingScreen)
         wait_for_elements_exist(landing_screen.hamburger_logo, :timeout => MAX_TIMEOUT)
        touch landing_screen.hamburger_logo
        sleep(STEP_PAUSE)
        touch landing_screen.how_to_help
        sleep(STEP_PAUSE)
        touch landing_screen.setup_sprocket_printer
    end
    await
  end

end