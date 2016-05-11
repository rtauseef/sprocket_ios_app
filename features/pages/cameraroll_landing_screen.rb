require 'calabash-cucumber/ibase'
require_relative '../common/base_html_screen'

class CameraRollLandingScreen < Calabash::IBase

  def trait
    social_media_logo
  end

  def social_media_logo
    "view marked:'HPSMS_logo.png'"
  end

  def instagram_logo
    "view marked:'LoginInstagram.png'"
  end

  def flickr_logo
    "view marked:'LoginFlickr.png'"
  end
    
    def cameraroll_logo
    "view marked:'LoginCameraRoll.png'"
  end
    
  def navigate
   
     sleep(WAIT_SCREENLOAD)
	  wait_for_elements_exist(cameraroll_logo,:timeout=>MAX_TIMEOUT)
      touch cameraroll_logo
      sleep(WAIT_SCREENLOAD)
     swipe_coach_marks_view

  end

end
