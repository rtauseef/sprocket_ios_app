require_relative '../common/base_html_screen'

class InstagramSigninScreen < BaseHtmlScreen

  def trait
    instagram_logo
  end

  def instagram_logo
    "webView css:'h1' {textContent LIKE 'Instagram'}"
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

  def instagram_login_button
    "webView css:'input' index:2"
  end
  
  def instagram_auth_button
    "webView css:'input' index:1"
    end

  def navigate
    if not current_page?
      welcome_screen = go_to(WelcomeScreen)
      touch welcome_screen.instagram_sign_in_button
      #wait_for_elements_exist("webView css:'h1' {textContent LIKE 'Instagram'}", :timeout => SOCIALMEDIA_TIMEOUT );
        sleep(WAIT_SCREENLOAD)
        social_media="webView css:'h1' {textContent LIKE 'Instagram'}"
        check_page_loaded social_media
    end
    await
  end
end
