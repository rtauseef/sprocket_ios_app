require 'calabash-cucumber/ibase'

class HashtagSearchResultScreen < Calabash::IBase

  def trait
    first_search
  end

  def first_search
     #"navigationItemView marked:'#healthy'"
      "label {text ENDSWITH 'posts'}"
  end




  def navigate
    unless current_page?
      search_screen = go_to(SearchScreen)
      wait_for_elements_exist("button marked:'Hashtag'", :timeout => MAX_TIMEOUT)
      touch("button marked:'Hashtag'")
      sleep(STEP_PAUSE)
      keyboard_enter_text("#healthy")
      done
      wait_for_elements_exist("tableViewCell index:0", :timeout => MAX_TIMEOUT)
      touch("tableViewCell index:0")
    end
    await
  end

end