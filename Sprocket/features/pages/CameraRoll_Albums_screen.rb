require 'calabash-cucumber/ibase'
require_relative '../common/base_html_screen'

class CameraRollAlbumsScreen < Calabash::IBase

  def trait
    cameraroll_album
  end

  def cameraroll_album
    "navigationBar label  marked:'Camera Roll Albums'"
  end

=begin
  def cameraroll_logo
    "UIImageView id:'CameraRoll'"
  end
=end

  def cameraroll_first_album
    "HPPRSelectAlbumTableViewCell"
  end

=begin
  def cameraroll_button
    "button marked:'Camera Roll'"
  end
=end
    
    def folder_icon
        "button marked:'folderIcon'"
    end
  
  def list_mode_button
    "button marked:'HPPRListViewOff'"
  end

  def grid_mode_button
    "button marked:'HPPRGridViewOff'"
  end
    def list_mode_check_button
        "view marked:'HPPRListViewOn'"
  end

    def grid_mode_check_button
      "view marked:'HPPRGridViewOn'"
  end
def second_photo
    "collectionViewCell index:1"
  end
  def navigate
    if not current_page?

      camera_roll_photos_screen = go_to(CameraRollPhotoScreen)
      sleep(WAIT_SCREENLOAD)
      wait_for_elements_exist(camera_roll_photos_screen.second_photo,:timeout=>MAX_TIMEOUT)
      touch folder_icon

    end
    close_camera_popup
      await
  end
end

