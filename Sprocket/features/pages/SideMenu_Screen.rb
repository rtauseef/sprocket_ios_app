require 'calabash-cucumber/ibase'
require_relative '../common/base_html_screen'

class SideMenuScreen < Calabash::IBase

  def trait
    #cameraroll_logo
      hp_logo
  end

  def hp_logo
    "* id:'HPLogo'"
  end


def cameraroll_button
    "button marked:'Camera Roll'"
  end
    
 def instagram_screen
    "window"
  end

 def navigate
     unless current_page?
         landing_screen = go_to(LandingScreen)
         touch landing_screen.hamburger_logo
         sleep(STEP_PAUSE)
     end
 end
end
