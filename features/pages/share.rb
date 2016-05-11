require 'calabash-cucumber/ibase'

class ShareScreen < Calabash::IBase

  def trait
    mail
    print
    save_to_camera
  end

  def mail
  "view marked:'Mail'"
  end

 def print
   "view marked:'Print'"
 end

  def save_to_camera
    "view marked:'Save to Camera Roll'"
  end

  def share_icon
    "view marked:'Share.png'"
  end
    
  def print_queue
    "view marked:'Print Queue' index:0"
  end

  def navigate
    unless current_page?
      select_template_screen = go_to(SelectTemplateScreen)
      sleep(WAIT_SCREENLOAD)
      screen_value="Print Queue"
      if $product_id == screen_value
            step %{I have disconnected wifi}
        end
        sleep(WAIT_SCREENLOAD)
      touch select_template_screen.share_icon
    end
    await
  end



end