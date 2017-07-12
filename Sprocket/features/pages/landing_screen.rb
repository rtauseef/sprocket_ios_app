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
    def google_logo
    "UIImageView marked:'google_C'"
  end
  
    
  def modal_content
    "label {text CONTAINS 'Make sure the printer is turned on and check the Bluetooth connection.'}"
  end

    def sprocket_option
        "view marked:'sprocket'"    
    end
    
def technical_info
    "label {text CONTAINS '#{$list_loc['Technical Information']}'}"
  end
  def close
    "UIButton index:1"
  end
    
    def how_to_help
        "view marked:'How to & Help'" 
    end
     def take_survey
        "view marked:'Take Survey'" 
    end
    def about
        "view marked:'About'" 
    end
    
    def reset_sprocket_printer
        "view marked:'Reset Sprocket Printer'" 
    end
    
    def setup_sprocket_printer
        "view marked:'Setup Sprocket Printer'" 
    end

 def social_source_auth_text
   query("TTTAttributedLabel label",:text)[0]
 end
def printers_option
  "view marked:'Printers'"
end
def terms_of_service_link
	 xcoord = query("TTTAttributedLabel").first["rect"]["center_x"]
  ycoord = query("TTTAttributedLabel").first["rect"]["center_y"]
  attr_width = query("TTTAttributedLabel").first["rect"]["width"]
  if get_device_name.to_s.start_with?('iPad')
    xcoord = xcoord +(attr_width.to_i/4)
    touch(nil, :offset => {:x => xcoord.to_i, :y => ycoord+10.to_i})
  else
      if ENV['LANGUAGE'] == "Turkish"
        touch(nil, :offset => {:x => xcoord-30.to_i, :y => ycoord+10.to_i})
      else
          if ENV['LANGUAGE'] == "Danish" || ENV['LANGUAGE'] == "Italian" || ENV['LANGUAGE'] == "Dutch" || ENV['LANGUAGE'] == "Estonian" || ENV['LANGUAGE'] == "Latvian" || ENV['LANGUAGE'] == "Norwegian" || ENV['LANGUAGE'] == "Portuguese" || ENV['LANGUAGE'] == "Swedish" || ENV['LANGUAGE'] == "Indonesian" || ENV['LANGUAGE'] == "Russian" || ENV['LANGUAGE'] == "Portuguese-Brazil"              
              touch(nil, :offset => {:x => xcoord+40.to_i, :y => ycoord+10.to_i})
          else
              if ENV['LANGUAGE'] == "Greek" || ENV['LANGUAGE'] == "Finnish"
                  touch(nil, :offset => {:x => xcoord+100.to_i, :y => ycoord+20.to_i})
              else
                  if ENV['LANGUAGE'] == "Canada-French" || ENV['LANGUAGE'] == "French"
                      touch(nil, :offset => {:x => xcoord-20.to_i, :y => ycoord+20.to_i})
                  else
                      touch(nil, :offset => {:x => xcoord+40.to_i, :y => ycoord+10.to_i})
                    #touch(nil, :offset => {:x => xcoord+50.to_i, :y => ycoord+20.to_i})
                  end
              end
          end
      end
    end
  end

  def navigate
          if element_exists("view marked:'sprocket'")
              $test = "sprocket"
          else 
              if element_exists("view marked:'„Sprocket“'")
                $test = "„Sprocket“"
              else
                  $test = "Sprocket"
              end
          end
      close_camera_popup
            if $language != nil
          ios_locale = $language_locale[$language]['ios_locale_id']
        else
          ios_locale = $language_locale["English-US"]['ios_locale_id']
        end
      $list_loc=$language_arr[ios_locale]      
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














