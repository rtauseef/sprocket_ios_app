require 'calabash-cucumber/ibase'
require_relative '../common/base_html_screen'

class CameraRollLandingScreen < Calabash::IBase

  def trait
    cameraroll_logo
  end

def cameraroll_logo
    "UIButtonLabel marked:'Camera Roll'"
  end
  def navigate
   if not current_page?

        landing_screen = go_to(LandingScreen)
         wait_for_elements_exist(landing_screen.cameraroll_logo, :timeout => MAX_TIMEOUT)
        touch landing_screen.cameraroll_logo
         sleep(STEP_PAUSE)
        swipe_coach_marks_view
      end
     swipe_coach_marks_view

  end

end
