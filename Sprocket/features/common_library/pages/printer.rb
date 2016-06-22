require 'calabash-cucumber/ibase'

class PrinterScreen < Calabash::IBase

  def trait
    printer
  end

  def printer
    #"navigationItemView marked:'Printer'"
      "view marked:'Printer'"
  end



  def navigate
    unless current_page?
      #printer_options = go_to(PrinterOptionsScreen)
      #touch printer_options.printers
        print_settings_screen = go_to(PageSettingsScreen)
        sleep(WAIT_SCREENLOAD)
        scroll("scrollView", :down)
        sleep(STEP_PAUSE)
            touch print_settings_screen.print_button
    end
    await

  end



end