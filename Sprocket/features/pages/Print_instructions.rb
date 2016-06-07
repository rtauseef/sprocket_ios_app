require 'calabash-cucumber/ibase'

class PrintInstructionsScreen < Calabash::IBase

  def trait
    print_instructions
  end

  def print_instructions
    "view marked:'Print Instructions'"
  end



  def navigate
    unless current_page?
      page_settings_screen = go_to(PrintSettingsScreen)
      touch page_settings_screen.help

    end
    await
  end



end