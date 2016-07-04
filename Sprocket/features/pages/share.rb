require 'calabash-cucumber/ibase'

class ShareScreen < Calabash::IBase

  def trait
    mail
    print
    save_to_camera
  end

  def mail
      "label marked:'Mail'"
  end

 def print
     "label marked:'Print'"
 end

  def save_to_camera
      "label marked:'Save to Camera Roll'"
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
        touch preview_screen.share
    end
    await
  end
end