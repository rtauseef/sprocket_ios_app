require 'calabash-cucumber/ibase'
require_relative '../common/base_html_screen'

class InstagramLandingScreen < Calabash::IBase

	def trait
        screen_title
	end
    
    def screen_title
        "UINavigationItemView label marked:'Instagram'"
    end

	def instagram_logo
		"UIImageView marked:'Instagram'"
  end



  def navigate

      if not current_page?

        landing_screen = go_to(LandingScreen)
         wait_for_elements_exist(landing_screen.instagram_logo, :timeout => MAX_TIMEOUT)
        touch landing_screen.instagram_logo
         sleep(STEP_PAUSE)
        swipe_coach_marks_view
      end
    await
  end
  end


