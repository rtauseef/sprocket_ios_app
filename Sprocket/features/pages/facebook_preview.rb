require 'calabash-cucumber/ibase'
require_relative '../common/base_html_screen'

class FacebookPreviewScreen < Calabash::IBase

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
         "* id:'editButton'"
  end

  def print
          "* id:'printButton'"
  end

  def share
         "* id:'shareButton'"
  end
 def navigate
    unless current_page?
      select_photo_screen = go_to(FacebookPhotoScreen)
        sleep(STEP_PAUSE)
	  wait_for_elements_exist(select_photo_screen.second_photo,:timeout=>MAX_TIMEOUT)
      touch select_photo_screen.second_photo
        sleep(WAIT_SCREENLOAD)
      close_camera_popup
    end

    await
  end
end