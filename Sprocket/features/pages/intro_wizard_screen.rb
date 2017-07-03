

require 'calabash-cucumber/ibase'

class IntroWizardScreen < Calabash::IBase

  def trait
      window
  end

    def window
        "* id:'Wizard_Sprocket'"
  end
    
    def load_paper
       "label marked:'Put the entire pack in the paper tray with barcode and HP logos facing down.'"
    end
    
    def skip
        "button marked:'Skip to the App'"
    end
    
    def power_up
       "label marked:'Press and hold the power button until the LED turns white.'"
    end
    
    def connect
       "label marked:'From Bluetooth Settings, tap on “HP sprocket” to pair with the printer.'"
    end
    
    def go_to_app
          "button marked:'Go to the App'"
    end
    
    def more_help
        "button marked:'More Help'"
    end

  def navigate
        await
  end

end