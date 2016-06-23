require 'calabash-cucumber/ibase'

class PaperTypeScreen < Calabash::IBase

  def trait
    page_type
  end

  def page_type
    "label marked:'Paper Type"
  end



  def navigate
    unless current_page?
      page_settings_screen = go_to(PageSettingsScreen)
      touch page_settings_screen.paper_size
      sleep(WAIT_SCREENLOAD)
      wait_for_elements_exist("view marked:'8.5 x 11'", :timeout => MAX_TIMEOUT)
      touch ("view marked:'8.5 x 11'")
      touch page_settings_screen.paper_type
      sleep(STEP_PAUSE)
    end
      await

  end



end