require 'calabash-cucumber/ibase'
require_relative '../common/base_html_screen'

class LandingScreen < Calabash::IBase

  def trait
    landing_page_logo
  end

  def landing_page_logo
    "view marked:'sprocket'"
  end

  def hamburger_logo
    "UIImageView id:'hamburger'"
  end

  def instagram_logo
    #"UIImageView id:'Instagram'"
      "view marked:'Instagram' index:0"
      
  end

  def flickr_logo
    "UIImageView id:'Flickr'"
  end

  def cameraroll_logo
    "UIImageView id:'CameraRoll'"
  end
    
    def cameraroll_logo_sidemenu
        "view marked:'Camera Roll'"
    end

  def facebook_logo
    "UIImageView id:'Facebook'"
  end
    
  def modal_title
    "label {text CONTAINS 'Printer not connected to device'}"
  end
    
  def modal_content
    "label {text CONTAINS 'Make sure the printer is turned on and check the Bluetooth connection.'}"
  end

    def sprocket_option
        "view marked:'sprocket'"    
    end
    
def technical_info
    "label {text CONTAINS 'Technical Information'}"
  end
  def close
    "UIButton index:1"
  end
    
    def how_to_help
        "view marked:'How to & Help'" 
    end
    
    def reset_sprocket_printer
        "view marked:'Reset Sprocket Printer'" 
    end
    
    def setup_sprocket_printer
        "view marked:'Setup Sprocket Printer'" 
    end
=begin
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

=end
 def social_source_auth_text
   query("TTTAttributedLabel label",:text)[0]
 end

  def terms_of_service_link
	xcoord = query("TTTAttributedLabel").first["rect"]["center_x"]
    ycoord = query("TTTAttributedLabel").first["rect"]["center_y"]
    if get_device_name.to_s.start_with?('iPad')
           touch(nil, :offset => {:x => xcoord+90.to_i, :y => ycoord+10.to_i})
    else
           touch(nil, :offset => {:x => xcoord+70.to_i, :y => ycoord+10.to_i})
    end
  end

  def navigate
      close_camera_popup
    await
  end

end














