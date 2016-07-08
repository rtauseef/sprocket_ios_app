Then(/^I should see "(.*?)" logo$/) do |arg|

  if arg=="Instagram"
    check_element_exists(@current_page.instagram_logo)
  else
    if arg=="Facebook"
      check_element_exists(@current_page.facebook_logo)
    else
      if arg=="Flickr"
        check_element_exists(@current_page.flickr_logo)
      else
        if arg=="Camera Roll"
          check_element_exists(@current_page.cameraroll_logo)

        else
          check_element_exists(@current_page.hamburger_logo)
        end
      end
    end

  end
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