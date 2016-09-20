require 'calabash-cucumber/ibase'

class UserSearchResultScreen < Calabash::IBase

  def trait
    first_search
  end

  def first_search
    #"navigationItemView marked:'@healthysmoothie'"
      "label {text BEGINSWITH '@'}"
  end




  def navigate
    unless current_page?
      search_screen = go_to(SearchScreen)
      wait_for_elements_exist("button marked:'Users'", :timeout => MAX_TIMEOUT)
      touch("button marked:'Users'")
      sleep(STEP_PAUSE)
      keyboard_enter_text("healthysmoothie")
      done
      wait_for_elements_exist("tableViewCell index:0", :timeout => MAX_TIMEOUT)
      touch("tableViewCell index:0")
    end
    await
  end

end