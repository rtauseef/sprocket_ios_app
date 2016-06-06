 #require_relative '../common/base_html_screen'
 require 'calabash-cucumber/ibase'


class CameraRollPhotoScreen < Calabash::IBase

	def trait
    select_photo
	end

  def select_photo
    "navigationBar label  marked:'Camera Roll Photos'"
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


  def navigate

    if not current_page?
        cameraroll_albm_screen = go_to(CameraRollAlbumsScreen)
        sleep(WAIT_SCREENLOAD)
         wait_for_elements_exist(cameraroll_albm_screen.cameraroll_first_album,:timeout=>MAX_TIMEOUT)
        touch cameraroll_albm_screen.cameraroll_first_album
         end
    await
  end

 end







