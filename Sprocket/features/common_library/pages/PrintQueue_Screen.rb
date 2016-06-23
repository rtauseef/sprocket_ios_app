require 'calabash-cucumber/ibase'
require_relative '../../common/base_html_screen'

class PrintQueueScreen < Calabash::IBase

  def trait
    screen_title
  end

  def cameraroll_logo
    "view marked:'LoginCameraRoll.png'"
  end

def screen_title
    "view marked:'Print Queue'"
  end
def cameraroll_button
    "button marked:'Camera Roll'"
  end
    
 def instagram_screen
    "window"
  end
   

 def navigate
     unless current_page?
      add_print_screen = go_to(AddPrintScreen)
      sleep(WAIT_SCREENLOAD)
       touch "view marked:'Add to Print Queue'"
          sleep(STEP_PAUSE)
       end
     
      
    await
    end

end