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
  
    
  def modal_content
    "label {text CONTAINS 'Make sure the printer is turned on and check the Bluetooth connection.'}"
  end

    def sprocket_option
        "view marked:'sprocket'"    
    end
    
def technical_info
    "label {text CONTAINS '#{$list_loc['Technical Information']}'}"
  end
  def close
    "UIButton index:1"
  end
    
    def how_to_help
        "view marked:'How to & Help'" 
    end
     def take_survey
        "view marked:'Take Survey'" 
    end
    def about
        "view marked:'About'" 
    end
    
    def reset_sprocket_printer
        "view marked:'Reset Sprocket Printer'" 
    end
    
    def setup_sprocket_printer
        "view marked:'Setup Sprocket Printer'" 
    end

 def social_source_auth_text
   query("TTTAttributedLabel label",:text)[0]
 end
def printers_option
  "view marked:'Printers'"
end


 def navigate
     unless current_page?
         landing_screen = go_to(LandingScreen)
         touch landing_screen.hamburger_logo
         sleep(STEP_PAUSE)
     end
 end
end
