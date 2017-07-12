require 'calabash-cucumber/ibase'

class SprocketScreen < Calabash::IBase

  def trait
      title
  end

  def title
      "navigationBar marked:'#{$list_loc['side_menu']}'"
  end
    
  def modal_title
    #"label {text CONTAINS 'Printer not connected to device'}"
      "label {text CONTAINS 'No sprockets Connected'}"
  end
=begin
    def close
    "UIButton index:1"
  end
=end
    def technical_info
    #"label {text CONTAINS 'Technical Information'}"
        "label {text CONTAINS '#{$list_loc['Technical Information']}'}"
  end
  def done
    "view marked:'Done'"
  end
    

  def navigate
    unless current_page?
      landing_screen = go_to(LandingScreen)
         wait_for_elements_exist(landing_screen.hamburger_logo, :timeout => MAX_TIMEOUT)
        touch landing_screen.hamburger_logo
        sleep(STEP_PAUSE)
        touch "view marked:'sprocket'"
        sleep(STEP_PAUSE)
    end
    await

  end

end