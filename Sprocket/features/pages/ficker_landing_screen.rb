require 'calabash-cucumber/ibase'
require_relative '../common/base_html_screen'

class FlickrLandingScreen < Calabash::IBase

	def trait
    screen_title
	end

	def flickr_logo
		"UIImageView marked:'Flickr'"
  end
  def screen_title
  "UINavigationItemView label marked:'Flickr'"
  end

def flickr_sign_in_button
  "button marked:'Sign in'"
end
    def username_input= username
    fill_input_field(username.to_s,0)
  end

  def password_input= password
    fill_input_field(password.to_s,1)
  end

  def set_text_to_input_field (text,input_id)
    touch("webView css:'input' index:#{input_id}")
    sleep(STEP_PAUSE)
    keyboard_enter_text text
    sleep(STEP_PAUSE)
  end

  def fill_input_field(text,input_id)

    set_text_to_input_field(text,input_id)

  end

  def clear_username
    touch("webView css:'#login-username'")
    wait_for_elements_exist("webView css:'.close-icon' index:0", :timeout => MAX_TIMEOUT)
    touch("webView css:'.close-icon' index:0")
    sleep(STEP_PAUSE)
  end

  def flickr_login_button
    "webView css:'#login-signin'"
  end


  def navigate

      if not current_page?

        landing_screen = go_to(LandingScreen)
         wait_for_elements_exist(landing_screen.flickr_logo, :timeout => MAX_TIMEOUT)
        touch landing_screen.flickr_logo
         sleep(STEP_PAUSE)
        swipe_coach_marks_view
      end
    await
  end
  end


