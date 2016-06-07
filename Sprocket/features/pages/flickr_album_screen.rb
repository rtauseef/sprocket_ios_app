 #require_relative '../common/base_html_screen'
 require 'calabash-cucumber/ibase'


class FlickrAlbumScreen < Calabash::IBase

  def trait
    flickr_albums
  end

  def flickr_albums
    "navigationBar label  marked:'Flickr Albums'"
  end

  def flickr_first_album
    "HPPRSelectAlbumTableViewCell index:0"
  end

  def hamburger
    "navigationItemButtonView first"
  end

  def About
    "tableViewCell text:'About'"
  end

  def Learn_printing
    "tableViewCell text:'Learn about Mobile Printing'"
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
    "view marked:'Search'"
  end

  def navigate

    device_name = get_device_name  
    sleep(STEP_PAUSE)
    if not current_page?
      landing_screen = go_to(LandingScreen)
      close_survey
      wait_for_elements_exist(landing_screen.flickr_logo, :timeout => MAX_TIMEOUT)
      touch landing_screen.flickr_logo
      sleep(STEP_PAUSE)
      swipe_coach_marks_view
        sleep(WAIT_SCREENLOAD)
      if element_exists("button marked:'Sign in'")
        welcome_screen = go_to(FlickrSigninScreen)
        sleep(WAIT_SCREENLOAD)
        welcome_screen.clear_username
        sleep(WAIT_SCREENLOAD)
        welcome_screen.fill_input_field(VALID_CREDENTIALS_Flickr[:user], 0)
        sleep(STEP_PAUSE)
		touch welcome_screen.flickr_login_button
        sleep(WAIT_SCREENLOAD)
        welcome_screen.fill_input_field(VALID_CREDENTIALS_Flickr[:password], 1)
        sleep(STEP_PAUSE)
        if device_name != "iPad"
            touch query("label marked:'Done'")
            sleep(STEP_PAUSE)
        end
		sleep(WAIT_SCREENLOAD)
        touch welcome_screen.flickr_login_button
        sleep(SLEEP_SCREENLOAD)
        scroll("scrollView", :down)        
        sleep(STEP_PAUSE)
        wait_for_elements_exist("webView css:'#auth-allow'", :timeout => MAX_TIMEOUT)
        scroll("scrollView", :down)
        sleep(STEP_PAUSE)
        touch "webView css:'#auth-allow'"
        sleep(WAIT_SCREENLOAD)
      end
    end

    await
  end

end





