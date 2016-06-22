require 'calabash-cucumber/ibase'
require_relative '../../common/base_html_screen'

class AddPrintScreen < Calabash::IBase

  def trait
    screen_title
  end

  def screen_title
    "view marked:'Add Print'"
  end

def add_to_print_queue
    "view marked:'Add to Print Queue'"
end
 def number_of_copies
    query( "label {text CONTAINS 'Cop'}", :text)[0].to_i
  end

  def increment_button
    "view marked:'Increment'"
  end

  def decrement_button
    "view marked:'Decrement'"
  end

 def navigate
     unless current_page?
         share_screen = go_to(ShareScreen)
        sleep(WAIT_SCREENLOAD)
      touch share_screen.print_queue
   # uia_tap_mark("Allow")
#    uia_tap_mark("Ok")
    end
    await
    end
end