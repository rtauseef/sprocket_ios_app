 #require_relative '../common/base_html_screen'
 require 'calabash-cucumber/ibase'


class FacebookSigninScreen < Calabash::IBase

	def trait
      window_title
	end

    def window_title
    device_agent.query({marked: "facebook"})
      end
    
  def navigate

    if not current_page?
        facebook_landing_screen = go_to(FacebookLandingScreen)
         touch "UIButtonLabel index:0"
    end
    await
  end

 end







