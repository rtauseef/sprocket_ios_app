require 'calabash-cucumber/ibase'

class ShareScreen < Calabash::IBase

  def trait
    #mail
    #print
    #save_to_camera
      icloud_photo_sharing
  end
    
    def icloud_photo_sharing
        "view marked:'iCloud Photo Sharing'"
    end
=begin 
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
=end

  def navigate
    unless current_page?
        preview_screen = go_to(InstagramPreviewScreen)
        sleep(WAIT_SCREENLOAD)
        #wait_for_elements_exist(preview_screen.share, :timeout => MAX_TIMEOUT)
        #touch preview_screen.share
        touch  query("* id:'shareButton'")
        sleep(WAIT_SCREENLOAD)
      
    end
    await
  end



end