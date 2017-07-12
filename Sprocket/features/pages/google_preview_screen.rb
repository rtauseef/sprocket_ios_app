require 'calabash-cucumber/ibase'

class GooglePreviewScreen < Calabash::IBase

  def trait
    camera
  end

  def camera
         "* id:'cameraButton'"
  end

  def cancel
    "button marked:'previewX'"
      
  end

  def edit
         "view marked:'Edit'"
  end

  def print
          "* id:'printButton'"
  end

  def share
         "* id:'shareButton'"
  end
    
    def download    
    "* id:'previewDownload'"
end
    
    def ok
        "UILabel marked:'#{$list_loc['ok']}'" 
    end
=begin 
    def more    
        "UILabel marked:'#{$list_loc['More']}' index:1"
end
=end
  def navigate
    unless current_page?
      select_photo_screen = go_to(GooglePhotosScreen)
      wait_for_elements_exist(select_photo_screen.second_photo, :timeout => MAX_TIMEOUT)
      touch select_photo_screen.second_photo
      sleep(WAIT_SCREENLOAD)
      close_camera_popup
    end      
      await
      $curr_img_frame_width = query("* id:'GestureImageView'").first["frame"]["width"]
    $curr_img_frame_height = query("* id:'GestureImageView'").first["frame"]["height"]
  end
end

  