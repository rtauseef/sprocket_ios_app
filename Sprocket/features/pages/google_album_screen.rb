 #require_relative '../common/base_html_screen'
 require 'calabash-cucumber/ibase'


class GoogleAlbumScreen < Calabash::IBase

  def trait
    #google_albums
    image_cell
  end

  def google_albums
     "view {text CONTAINS 'Google'}"
  end

  def google_first_album
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

    def arrow_down
    "* id:'arrowDown'"
  end
    def image_cell
    "HPPRSelectAlbumTableViewCell"
  end
  def navigate

    device_name = get_device_name  
    sleep(STEP_PAUSE)
    if not current_page?
      puts "not current"
      landing_screen = go_to(LandingScreen)
      #close_survey
      wait_for_elements_exist(landing_screen.google_logo, :timeout => MAX_TIMEOUT)
      touch landing_screen.google_logo
      sleep(STEP_PAUSE)
      swipe_coach_marks_view
      sleep(WAIT_SCREENLOAD)
      if element_exists("button marked:'Sign In'")
        touch query("button marked:'Sign In'")
        screen_name = "GoogleSignin"
        required_page = page_by_name(screen_name)
        @current_page = required_page
        puts "current"
        puts @current_page
        sleep(10.0)
        #welcome_screen = go_to(GoogleSigninScreen)
        sleep(WAIT_SCREENLOAD)        
        @current_page.fill_input_field(VALID_CREDENTIALS_Google[:user],0)
        device_agent.touch({marked:"NEXT" })
        sleep(WAIT_SCREENLOAD)
        @current_page.fill_password_field(VALID_CREDENTIALS_Google[:password],0)
        sleep(WAIT_SCREENLOAD)
        device_agent.touch({marked:"NEXT" })
        sleep(5.0)
        @current_page.google_auth_button
        sleep(5.0)
        swipe_coach_marks_view
        sleep(WAIT_SCREENLOAD)
      end
        if element_exists(arrow_down)
          touch arrow_down
        end
    end
    await
  end

end





