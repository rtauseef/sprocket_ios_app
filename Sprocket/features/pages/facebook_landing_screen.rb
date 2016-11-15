require 'calabash-cucumber/ibase'
require_relative '../common/base_html_screen'

class FacebookLandingScreen < Calabash::IBase

	def trait
    facebook_logo
 end

 def facebook_logo
  "UIButtonLabel marked:'Facebook'"
  end
def sign_in_button
  "button marked:'Sign in'"
end


  def navigate

      if not current_page?
         close_camera_popup
        landing_screen = go_to(LandingScreen)
         wait_for_elements_exist(landing_screen.facebook_logo, :timeout => MAX_TIMEOUT)
        touch landing_screen.facebook_logo
         sleep(STEP_PAUSE)
        swipe_coach_marks_view
      end
    await
  end
  end


