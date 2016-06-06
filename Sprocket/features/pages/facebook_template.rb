require 'calabash-cucumber/ibase'
require_relative '../common/base_html_screen'

class FacebookSelectTemplateScreen < Calabash::IBase

  def trait
    select_template
  end

  def cameraroll_logo
    "view marked:'LoginCameraRoll.png'"
  end

def select_template
    "navigationBar marked:'Select Template'"
  end
    
def cameraroll_button
    "button marked:'Camera Roll'"
  end
   def instagram_screen
    "window"
  end

    def selected_template
  query("collectionView marked:'TemplateCollectionView'",:accessibilityValue).first
  end
 def navigate
    unless current_page?
      select_photo_screen = go_to(FacebookPhotoScreen)
        sleep(STEP_PAUSE)
	  wait_for_elements_exist(select_photo_screen.second_photo,:timeout=>MAX_TIMEOUT)
      touch select_photo_screen.second_photo
    end

    await
  end
end