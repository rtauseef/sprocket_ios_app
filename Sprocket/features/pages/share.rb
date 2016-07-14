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
        preview_screen = go_to(PreviewScreen)
        sleep(WAIT_SCREENLOAD)
        wait_for_elements_exist(preview_screen.share, :timeout => MAX_TIMEOUT)
        touch preview_screen.share
        sleep(WAIT_SCREENLOAD)
      
    end
    await
  end



end