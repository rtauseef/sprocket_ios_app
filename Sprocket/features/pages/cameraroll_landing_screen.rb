require 'calabash-cucumber/ibase'
require_relative '../common/base_html_screen'

class CameraRollLandingScreen < Calabash::IBase

  def trait
    social_media_logo
  end


  def navigate
   
     sleep(WAIT_SCREENLOAD)
	  wait_for_elements_exist(cameraroll_logo,:timeout=>MAX_TIMEOUT)
      touch cameraroll_logo
      sleep(WAIT_SCREENLOAD)
     swipe_coach_marks_view

  end

end
