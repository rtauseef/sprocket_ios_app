

require 'calabash-cucumber/ibase'

class TechnicalInformationScreen < Calabash::IBase

  def trait
      title
  end

  def title
     # "navigationBar marked:'Technical Information'"
      "navigationBar marked:'#{$list_loc['Technical Information']}'"
  end
    
    def back
       "view marked:'Back'"
    end
    
    def back_button
       "view marked:'#{$list_loc['Back']}'"
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
        touch landing_screen.sprocket_option
        sleep(STEP_PAUSE)
        touch landing_screen.printers_option
        sleep(STEP_PAUSE)
        touch landing_screen.technical_info
    end
    await
  end

end