require 'calabash-cucumber/ibase'
require_relative '../common/base_html_screen'

class LandingScreen < Calabash::IBase

  def trait
    landing_page_logo
  end

  def landing_page_logo
      "view marked:'#{$test}'"
  end

  def hamburger_logo
    "UIImageView id:'hamburger'"
  end

  def instagram_logo
      #"view marked:'Instagram' index:0"
      "view marked:'#{$list_loc['Instagram']}' index:0"
  end

  def flickr_logo
    "UIImageView id:'Flickr'"
  end

  def cameraroll_logo
    #"UIImageView id:'CameraRoll'"
      "UIImageView id:'#{$list_loc['cameraroll_logo']}'"
  end
    
    def cameraroll_logo_sidemenu
        "view marked:'Camera Roll'"
    end

  def facebook_logo
    "UIImageView id:'Facebook'"
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
  attr_width = query("TTTAttributedLabel").first["rect"]["width"]
  if get_device_name.to_s.start_with?('iPad')
    xcoord = xcoord +(attr_width.to_i/4)
    touch(nil, :offset => {:x => xcoord.to_i, :y => ycoord+10.to_i})
  else
    touch(nil, :offset => {:x => xcoord+10.to_i, :y => ycoord+10.to_i})
    end
  end

  def navigate
          if element_exists("view marked:'sprocket'")
              $test = "sprocket"
          else
              $test = "Sprocket"
          end
      close_camera_popup
       if ENV['LANGUAGE'] == "Spanish"
     $list_loc=$language_arr["es_ES"]
       else if ENV['LANGUAGE'] == "Chinese"
                 $list_loc=$language_arr["zh_Hans"]
       else if ENV['LANGUAGE'] == "German"
           $list_loc=$language_arr["de_DE"]
       else if ENV['LANGUAGE'] == "French"
           $list_loc=$language_arr["fr_FR"]
        else if ENV['LANGUAGE'] == "Italian"
           $list_loc=$language_arr["it_IT"]
       else if ENV['LANGUAGE'] == "Dutch"
           $list_loc=$language_arr["nl_NL"]
        else if ENV['LANGUAGE'] == "Danish"
           $list_loc=$language_arr["da_DK"]
       else
        $list_loc=$language_arr["en_US"]
       end
       end
       end
       end
       end
       end
  end
  survey_message_arr = $list_loc['survey']
  if get_xcode_version.to_i < 8
        survey_message=uia_query :view, marked:"#{survey_message_arr}"
        if survey_message.length >0
            uia_tap_mark("#{survey_message_arr}")
        end
    else
      survey_message = device_agent.query({marked:"#{survey_message_arr}"})
      if survey_message.length >0
        device_agent.touch({marked:"#{survey_message_arr}"})
      end
      sleep(WAIT_SCREENLOAD)
    end
    await
  end

end














