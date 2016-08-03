require 'calabash-cucumber/ibase'

class SelectPrinterScreen < Calabash::IBase
    
  def trait
      select_printer
  end

    def select_printer
        "navigationBar marked:'Select Printer'"
  end
        
  def navigate
    unless current_page?
        preview_screen = go_to(PreviewScreen)
      touch preview_screen.print
    end
      await
  end
end
    
  

