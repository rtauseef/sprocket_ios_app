require 'calabash-cucumber/ibase'

class GoogleLandingScreen < Calabash::IBase

	def trait
    screen_title
	end

	def google_logo
    "UIImageView marked:'google_C'"
  end
  def screen_title
  "label marked:'Google'"
  end

  def navigate

      if not current_page?

        landing_screen = go_to(LandingScreen)
         wait_for_elements_exist(landing_screen.google_logo, :timeout => MAX_TIMEOUT)
        touch landing_screen.google_logo
         sleep(STEP_PAUSE)
        swipe_coach_marks_view
      end
    await
  end
  end


