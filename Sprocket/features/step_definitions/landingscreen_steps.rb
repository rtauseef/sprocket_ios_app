Then(/^I should see "(.*?)" logo$/) do |arg|

  if arg=="Instagram"
      if ENV['LANGUAGE'] == "Chinese" || ENV['LANGUAGE'] == "Chinese-Traditional"
          if element_exists("view marked:'sprocket'")
              touch query "UIButton index:1"
              sleep(STEP_PAUSE)
          end
      end
      check_element_exists(@current_page.instagram_logo)
  else
    if arg=="Facebook"
      check_element_exists(@current_page.facebook_logo)
    else
      if arg=="Flickr"
          if ENV['LANGUAGE'] =='Chinese' || ENV['LANGUAGE'] == 'Chinese-Traditional'
              puts "Flickr not applicable for Chinese".blue
              skip_this_scenario
          else
            check_element_exists(@current_page.flickr_logo)
          end
      else
        if arg=="Camera Roll"
            if element_exists("* text:'Sign In'")
                check_element_exists(@current_page.cameraroll_logo_sidemenu)
            else
                check_element_exists(@current_page.cameraroll_logo)
            end
        else
          if arg=="Sprocket"
            check_element_exists(@current_page.sprocket_logo)
          else
            if arg=="Hamburger"
              check_element_exists(@current_page.hamburger_logo)
            end
          end
        end
      end
    end
  end
end

Then(/^I tap "(.*?)"$/) do |social_source|
  if element_exists("UIImageView id:'#{social_source}'")
    touch ("UIImageView id:'#{social_source}'")
  end
  swipe_coach_marks_view
end

And(/^I should see social source authentication text$/) do
  sleep(MIN_TIMEOUT)
  exp_auth_text="By authenticating with social sources you also agree to HP Terms of Service."
  compare = (@current_page.social_source_auth_text == exp_auth_text) ? true : false
  raise "Authentication text mismatch" unless compare==true
end

When(/^I touch the Terms of Service link$/) do
  @current_page.terms_of_service_link


  sleep(WAIT_SCREENLOAD)
end