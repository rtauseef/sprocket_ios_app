require 'calabash-cucumber/ibase'

class PaperSizeScreen < Calabash::IBase

  def trait
    page_size
  end

  def page_size
    "navigationItemView marked:'Paper Size'"
  end



  def navigate
    unless current_page?
      page_settings_screen = go_to(PageSettingsScreen)
      sleep(WAIT_SCREENLOAD)
        scroll("tableView", :down)
        sleep(STEP_PAUSE)
        wait_for_elements_exist(page_settings_screen.size, :timeout => MAX_TIMEOUT)
     touch page_settings_screen.size
      sleep(STEP_PAUSE)
    end
   await
  end

end
