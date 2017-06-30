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
      if arg=="Google"
          if ENV['LANGUAGE'] =='Chinese' || ENV['LANGUAGE'] == 'Chinese-Traditional'
              puts "Google not applicable for Chinese".blue
              skip_this_scenario
          else
            check_element_exists(@current_page.google_logo)
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
  if social_source == "Google"
    social_source = "google_C"
  end
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

Then(/^I verify the instructions to "(.*?)"$/) do |instruction|
    if instruction == "load the paper"
        check_element_exists(@current_page.load_paper)
    else
        if instruction == "connect"
            check_element_exists(@current_page.connect)
        else
            check_element_exists(@current_page.power_up)
        end
    end
end

Then(/^I should see "(.*?)" page$/) do |page|
    check_element_exists("label marked:'How To & Help'")
    sleep(STEP_PAUSE)
end