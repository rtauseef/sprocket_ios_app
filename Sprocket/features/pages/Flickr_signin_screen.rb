require_relative '../common/base_html_screen'

class FlickrSigninScreen < BaseHtmlScreen

  def trait
    flickr_username
  end

  def flickr_username
    "webView css:'#login-username'"
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
          welcome_screen = go_to(FlickrLandingScreen)
          sleep(WAIT_SCREENLOAD)
          wait_for_elements_exist(welcome_screen.flickr_sign_in_button, :timeout => MAX_TIMEOUT)
          #touch welcome_screen.flickr_sign_in_button
          touch "button marked:'Sign in'"
          sleep(WAIT_SCREENLOAD)
          social_media="webView css:'#login-username'"
          check_page_loaded social_media
      end
      await
  end
end
