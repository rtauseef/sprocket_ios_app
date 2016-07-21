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