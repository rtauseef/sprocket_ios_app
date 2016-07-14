require 'calabash-cucumber/ibase'
require_relative '../common/base_html_screen'

class FacebookAlbumsScreen < Calabash::IBase

  def trait
    facebook_album
  end

  def facebook_album
    "navigationBar label  marked:'Facebook Albums'"
  end
    
    def cameraroll_logo
    "view marked:'LoginCameraRoll.png'"
  end
    
    def folder_icon
    "button marked:'folderIcon'"
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
       touch folder_icon
        end 
     await
end
end