#require_relative '../common/base_html_screen'
require 'calabash-cucumber/ibase'


class HomeScreen < Calabash::IBase

  def trait
    select_photo
  end

  def select_photo
    "navigationBar label  marked:'Instagram Photos'"
  end
  
  def grid_mode_button
    "button marked:'HPPRGridViewOff'"
  end

  def list_mode_button
    "button marked:'HPPRListViewOff'"
  end
    def list_mode_check_button
        "view marked:'HPPRListViewOn'"
  end

    def grid_mode_check_button
      "view marked:'HPPRGridViewOn'"
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
    count = first_from query "collectionView", numberOfItemsInSection: 0
    count.to_i
  end

  def photos_scroll_count
    photos_count = query("collectionView", numberOfItemsInSection: 0)[0]
    view_photo_at_position photos_count
    count = first_from query "collectionView", numberOfItemsInSection: 0
    count.to_i
  end

  def second_photo
    "collectionViewCell index:1"
  end

  def hamburger
    "navigationItemButtonView first"
  end

  def About
    "tableViewCell text:'About'"
  end

  def Learn_printing
    "tableViewCell text:'Print Instructions'"
  end

  def send_feedback
    "tableViewCell text:'Send Feedback'"
  end

  def take_survey
    "tableViewCell text:'Take our Survey'"
  end

  def privacy_statement
    "tableViewCell text:'Privacy Statement'"
  end

  def search
    "view marked:'HPPRSearch'"
  end

  def navigate

    if not current_page?
        close_survey
      landing_screen = go_to(LandingScreen)
        wait_for_elements_exist(landing_screen.instagram_logo, :timeout => MAX_TIMEOUT)
      touch landing_screen.instagram_logo
      sleep(WAIT_SCREENLOAD)
      swipe_coach_marks_view
      sleep(WAIT_SCREENLOAD)
      if element_exists("button marked:'Sign in'")
        welcome_screen = go_to(InstagramSigninScreen)
        sleep(WAIT_SCREENLOAD)
        welcome_screen.fill_input_field(VALID_CREDENTIALS[:user], 0)
        welcome_screen.fill_input_field(VALID_CREDENTIALS[:password], 1)
        touch welcome_screen.instagram_login_button
        sleep(SLEEP_SCREENLOAD)
        if element_exists("webView css:'input' index:1")
          touch welcome_screen.instagram_auth_button
        end
        sleep(STEP_PAUSE)
      end

    end
    await
  end

end