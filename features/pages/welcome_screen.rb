require 'calabash-cucumber/ibase'
require_relative '../common/base_html_screen'

class WelcomeScreen < Calabash::IBase

	def trait
	    instagram_sign_in_button
	end

	def instagram_sign_in_button
		"button marked:'Sign in'"
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


  def instagram_login_button
    "webView css:'input' index:2"
  end

  def clear_username
    touch("webView css:'#login-username'")
    wait_for_elements_exist("webView css:'.close-icon' index:0", :timeout => MAX_TIMEOUT)
    touch("webView css:'.close-icon' index:0")
    if element_does_not_exist("view:'UIKeyboardAutomatic'")
      touch("webView css:'#login-username'")
    end
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
