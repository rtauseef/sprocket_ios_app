require 'calabash-cucumber/ibase'

class AboutScreen < Calabash::IBase

  def trait
    about
  end

  def about
      "view marked:'#{$list_loc['About']}'"
  end

def build_version
    query("UILabel index:3",:text)[0]
end
def sprocket_logo
    "* id:'aboutLogo'"
end
    
def done
    "view marked:'Done'"
end
    
  def navigate
    unless current_page?
      landing_screen = go_to(LandingScreen)
      touch landing_screen.hamburger_logo
      sleep(STEP_PAUSE)
      touch landing_screen.about
      sleep(STEP_PAUSE)
    end
  end



end