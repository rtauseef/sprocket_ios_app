require 'calabash-cucumber/ibase'
require_relative '../common/base_html_screen'

class FacebookAlbumsScreen < Calabash::IBase

  def trait
    facebook_album
  end

  def facebook_album
    #"navigationBar label  marked:'Facebook Albums'"
      "label marked:'Facebook'"
  end
    
    def cameraroll_logo
    "view marked:'LoginCameraRoll.png'"
  end
    
    def arrow_down
    "* id:'arrowDown'"
  end
    
 def first_album
    "HPPRSelectAlbumTableViewCell index:1"
  end
    def second_photo
    "collectionViewCell index:1"
  end
 

 def navigate
   if not current_page?
       landing_screen = go_to(LandingScreen)
       close_survey
        wait_for_elements_exist(landing_screen.facebook_logo,:timeout=>MAX_TIMEOUT)
       touch landing_screen.facebook_logo
       touch arrow_down
        end 
     await
end
end