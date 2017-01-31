

require 'calabash-cucumber/ibase'

class ResetSprocketPrinterScreen < Calabash::IBase

  def trait
      title
  end

  def title
      #"navigationBar marked:'#{$list_loc['Reset Sprocket Printer']}'"
      "UINavigationBar {accessibilityIdentifier CONTAINS '#{$list_loc['reset_sprocket']}'}"
  end
    
    def back
       "view marked:'Back'"
    end

    def close
    "UIButton index:1"
  end


  def navigate
    unless current_page?
      landing_screen = go_to(LandingScreen)
         wait_for_elements_exist(landing_screen.hamburger_logo, :timeout => MAX_TIMEOUT)
        touch landing_screen.hamburger_logo
        sleep(STEP_PAUSE)
        touch landing_screen.how_to_help
        sleep(STEP_PAUSE)
        touch landing_screen.reset_sprocket_printer
    end
    await
  end

end