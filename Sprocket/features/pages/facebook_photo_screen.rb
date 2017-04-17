 #require_relative '../common/base_html_screen'
 require 'calabash-cucumber/ibase'


class FacebookPhotoScreen < Calabash::IBase

	def trait
    select_photo
	end

  def select_photo
    "navigationBar label  marked:'Facebook Photos'"
  end
    
    def arrow_down
        "* id:'arrowDown'"
    end

  def all_visible_photos
    query "all collectionViewCell"
  end

  def fully_visible_photos
    query("collectionViewCell")
  end


 def photo_width
    photos = fully_visible_photos
    raise "No cards found" unless photos.count > 0
    raise "Not able to verify. It's necessary to have at least 2 photos to determine" unless all_visible_photos.count > 1
     photos.first["frame"]["width"]

  end

  def thumbnail_for_photo_at_position index
    view_photo_at_position index
    first_from query "collectionViewCell imageView", :image
  end

  def view_photo_at_position index
    position = index.to_i - 1
    scroll_to_collection_view_item position, 0, scroll_position: :top, animate: true
    wait_for_none_animating
  end
  def view_last_photo
      photos_count = query("collectionView", numberOfItemsInSection: 0)[0]
      view_photo_at_position photos_count

  end

  def photos_count
      count = first_from query "collectionView", numberOfItemsInSection:0
      count.to_i
  end

  def photos_scroll_count
     photos_count = query("collectionView", numberOfItemsInSection: 0)[0]
     view_photo_at_position photos_count
     count = first_from query "collectionView", numberOfItemsInSection:0
     count.to_i
  end

  def second_photo
    "UIImageView index:4"
  end
def list_mode_check_button
    "* id:'listViewOnIcon'"
  end

  def grid_mode_check_button
    "* id:'gridViewOnIcon'"
  end
    def list_mode_button
    "* id:'listViewOffIcon'"
  end
def grid_mode_button
    "* id:'gridViewOffIcon'"
  end
  def navigate

    if not current_page?
        cameraroll_albm_screen = go_to(FacebookSigninScreen)
        sleep(WAIT_SCREENLOAD)
            uia_tap_mark("Email address or phone number")
            uia_wait_for_keyboard
            uia_set_responder_value(VALID_CREDENTIALS_Facebook[:user],0)
            uia_tap_mark("Facebook password")
            uia_set_responder_value(VALID_CREDENTIALS_Facebook[:user],1)
            sleep(STEP_PAUSE)
            uia_tap_mark("Log In")
            sleep(WAIT_SCREENLOAD)
            uia_tap_mark("OK")
        end
    await
  end

 end







