require 'calabash-cucumber/ibase'
require_relative '../common/base_html_screen'

class CameraRollPreviewScreen < Calabash::IBase

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
    
    def check
        "view marked:'editor-tool-apply-btn'"
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
    
    def checkmark
        "* id:'Check_Inactive1.png'" 
    end
    
    def more    
        "UILabel marked:'#{$list_loc['More']}' index:1"
end
    
    def preview_bar_dots
       "* id:'PreviewBarDots'" 
    end
    
    def print_queue
        "view marked:'Print Queue'" 
    end
    
    def increment
        "* id:'+ButtonEnabled'"
    end
    
    def decrement
        "* id:'-ButtonEnabled'"
    end
    
def close
    "button"
  end
def navigate
  unless current_page?
    select_photo_screen = go_to(CameraRollPhotoScreen)
    sleep(WAIT_SCREENLOAD)
	  wait_for_elements_exist(select_photo_screen.second_photo,:timeout=>MAX_TIMEOUT)
      touch select_photo_screen.second_photo
        sleep(WAIT_SCREENLOAD)
      close_camera_popup
    end
    await
     $curr_img_frame_width = query("* id:'GestureImageView'").first["frame"]["width"]
    $curr_img_frame_height = query("* id:'GestureImageView'").first["frame"]["height"]
  end
end