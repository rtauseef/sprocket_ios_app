require 'calabash-cucumber/ibase'

class PreviewScreen < Calabash::IBase

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
      select_photo_screen = go_to(HomeScreen)
      sleep(WAIT_SCREENLOAD)
    end
    sleep(STEP_PAUSE)
    touch query("collectionViewCell index:1")
    sleep(WAIT_SCREENLOAD)
      close_camera_popup
      await
  end
end

  

