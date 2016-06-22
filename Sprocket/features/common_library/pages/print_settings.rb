    require 'calabash-cucumber/ibase'

class PrintSettingsScreen < Calabash::IBase

  def trait
    print_settings
  end

  def print_settings
    "view marked:'Print Settings'"
  end

  def selected_printer_name
    query("UITableViewLabel index:1",:text)[0]
  end

  def navigate
    unless current_page?
      pagesettings_screen = go_to(PageSettingsScreen)
      touch pagesettings_screen.settings
    end
    await
  end



end