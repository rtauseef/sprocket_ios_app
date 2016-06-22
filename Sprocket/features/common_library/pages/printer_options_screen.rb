require 'calabash-cucumber/ibase'


class PrinterOptionsScreen < Calabash::IBase

  def trait
    printer_options
  end

  def printer_options
    #"label marked:'Printer Options'"
      "label marked:'Printer'"
  end

  def printers
   "view marked:'Printer'"
  end

  def select_printer
    "view marked:'Select Printer'"
  end

  def navigate
    unless current_page?
      page_settings_screen = go_to(PageSettingsScreen)
      touch page_settings_screen.print_button
      sleep(STEP_PAUSE)
    end
    await
  end



end