require 'calabash-cucumber/ibase'
require_relative '../../common/base_html_screen'

class PrintQueWifiOnScreen < Calabash::IBase

  def trait
    cameraroll_logo
  end

  def cameraroll_logo
    "view marked:'LoginCameraRoll.png'"
  end


def cameraroll_button
    "button marked:'Camera Roll'"
  end
    
 def instagram_screen
    "window"
  end

 def navigate
   
     sleep(2.0)
      touch cameraroll_logo
      sleep(2.0)
       touch("view marked:'Hamburger'")
     sleep(2.0)
   
  end

end
