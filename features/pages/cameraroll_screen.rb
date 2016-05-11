require 'calabash-cucumber/ibase'
require_relative '../common/base_html_screen'

class CameraRollScreen < Calabash::IBase

	def trait
    cameraroll_logo
	end

	def cameraroll_logo
		"UIImageView marked:'CameraRoll'"
  end

def cameraroll_button
  "button marked:'Camera Roll'"
end

  def navigate

      if not current_page?

        landing_screen = go_to(CameraRollLandingScreen)
         wait_for_elements_exist(landing_screen.cameraroll_logo,:timeout=>MAX_TIMEOUT)
        touch landing_screen.cameraroll_logo
        swipe_coach_marks_view
      end
    await
  end
  end


