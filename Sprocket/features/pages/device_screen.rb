require 'calabash-cucumber/ibase'

class DeviceScreen < Calabash::IBase

  def trait
      title
  end

  def title
    "navigationBar marked:'Devices'"
  end
    
  def message_title
    "label {text CONTAINS 'Pair your bluetooth printer with this device.'}"
  end
  def close_button
    "* id:'MPX.png'"
  end
    
    def printer_1
        ("UITableViewCell index:0")
    end
    
    def printer_2
        ("UITableViewCell index:1")
    end
    
    def navigate_back
        "UINavigationButton marked:'Back'"
    end
    
    def errors
        "UITableViewLabel index:1"
    end
    
    def battery_status
        "UITableViewLabel index:3"
    end
    
    def auto_off
        "UITableViewLabel index:5"
    end
    
    def mac_address
        "UITableViewLabel index:7"
    end
    
    def firmware_version
        "UITableViewLabel index:9"
    end
    
    def hardware_version
        "UITableViewLabel index:11"
    end
    

  def navigate
    unless current_page?
      landing_screen = go_to(LandingScreen)
         wait_for_elements_exist(landing_screen.hamburger_logo, :timeout => MAX_TIMEOUT)
        touch landing_screen.hamburger_logo
        sleep(STEP_PAUSE)
        touch "view marked:'Devices'"
        sleep(STEP_PAUSE)
        if element_exists("label {text CONTAINS 'Printer not connected to device'}")
            touch "label {text CONTAINS 'OK'}"
        end
    end
    await

  end

end