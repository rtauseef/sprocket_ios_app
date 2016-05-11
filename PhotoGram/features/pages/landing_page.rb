require 'calabash-cucumber/ibase'
require_relative '../common/base_html_screen'

class LandingScreen < Calabash::IBase

  def trait
    social_media_logo
  end

  def social_media_logo
    "view marked:'HPSMS_logo.png'"
  end

  def instagram_logo
    "view marked:'LoginInstagram.png'"
  end

  def flickr_logo
    "view marked:'LoginFlickr.png'"
  end
    def cameraroll_logo
    "view marked:'LoginCameraRoll.png'"
  end
    def facebook_logo
    "view marked:'LoginFacebook.png'"
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
        await
      end

end














