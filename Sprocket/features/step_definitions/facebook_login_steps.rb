
Then /^I wait for sometime$/ do
    sleep(SLEEP_SCREENLOAD) 
end    

Given(/^I am on the Landing screen$/) do
    $proxy_http=ENV['http_proxy']
    $proxy_https=ENV['https_proxy']
    ENV['http_proxy']=nil
    ENV['https_proxy']=nil
	path =File.expand_path("../../common_library/support/runme.sh", __FILE__)
	system(path)
    sleep(MAX_TIMEOUT)
    sleep(MAX_TIMEOUT)
    selenium.start_driver
    sleep(WAIT_SCREENLOAD)
    if $language != nil
        ios_locale = $language_locale[$language]['ios_locale_id']
    else
        ios_locale = $language_locale["English-US"]['ios_locale_id']
    end
    $list_loc=$language_arr[ios_locale]
    sleep(SLEEP_MIN)
    if selenium.find_elements(:name,"#{$list_loc['survey']}").size > 0
        selenium.find_element(:name,"#{$list_loc['survey']}").click
    end
    if selenium.find_elements(:xpath,"//UIAButton[@name='#{$list_loc['skip_to_the_app']}']").size > 0
        selenium.find_element(:xpath,"//UIAButton[@name='#{$list_loc['skip_to_the_app']}']").click
    end
    if selenium.find_elements(:xpath,"//UIAStaticText[@value='sprocket']").size > 0
        $test = "sprocket"
    else 
        if selenium.find_elements(:xpath,"//UIAStaticText[@value='Sprocket']").size > 0
            $test = "Sprocket"
        else
            $test = "„Sprocket“"
        end
    end
    camera_pop_up = "//UIAApplication[1]/UIAWindow[1]/UIAAlert[1]/UIACollectionView[1]/UIACollectionCell[1]/UIAButton[1]"
    if selenium.find_elements(:xpath,"#{camera_pop_up}").size > 0
        selenium.find_elements(:xpath,"#{camera_pop_up}").click
    end
    raise "Wrong screen!" unless (selenium.find_elements(:xpath,"//UIAStaticText[@value='#{$test}']").size) > 0
end

Then(/^I should see the "(.*?)" Logo$/) do |photo_source|
    sleep(WAIT_SCREENLOAD)
    $photo_source = photo_source
    if photo_source == "Facebook"
        value = "//UIAButton[@name='Facebook']"
    end
    raise "#{photo_source} logo not found!" unless (selenium.find_elements(:xpath,"#{value}").size) > 0
end
Then(/^I touch the "(.*?)" Logo$/) do |photo_source|
    $photo_source = photo_source
    if photo_source == "Facebook"
        value = "//UIAButton[@name='Facebook']"
    else
        if photo_source == "Photos"
            value = "//XCUIElementTypeButton[@name='CameraRoll']"
        end
    end
    selenium.find_element(:xpath,"#{value}").click
end

When(/^I touch signin button$/) do
    sleep(WAIT_SCREENLOAD)
    action = Appium::TouchAction.new
    action.swipe start_x: 50,offset_x: 300,start_y: 100,offset_y: 100,duration: 1000
    action.perform 
    sleep(WAIT_SCREENLOAD)
    if $photo_source != "Photos"
        sign_in_button="//UIAButton[@name='Sign In']"
        if selenium.find_elements(:xpath,"#{sign_in_button}").size > 0
            selenium.find_element(:xpath,"#{sign_in_button}").click
        end
    end
end


Given(/^I login to facebook$/) do
    path =File.expand_path("../../common_library/support/runme.sh", __FILE__)
    system(path)
    sleep(SLEEP_MAX)
    if get_os_version.to_f < 9.0
        puts "Logging to facebook via safari!" .blue
    else
      sleep(SLEEP_SCREENLOAD)
        txtFBEmail="//UIATextField[@value='Email address or phone number']"
        if get_os_version.to_f < 10.0
            txtFBEmail="//UIATextField[@value='Email address or phone number']"
            txtFBPassword="//UIASecureTextField[@value='Facebook password']"
            btnFBLogin= "//UIAButton[@name='Log In']"
            btnFBConfirm= "//UIAButton[@name='Continue']"
        else
            txtFBEmail="//XCUIElementTypeTextField[@value='Email address or phone number']"
            txtFBPassword="//XCUIElementTypeSecureTextField[@value='Facebook password']"
            btnFBLogin= "//XCUIElementTypeButton[@name='Log In']"
            btnFBConfirm= "//XCUIElementTypeButton[@name='Continue']"
            
        end
        wait = Selenium::WebDriver::Wait.new(:timeout => MAX_TIMEOUT) # seconds
        wait.until { selenium.find_element(:xpath,"#{txtFBEmail}") }
        selenium.find_element(:xpath,"#{txtFBEmail}").click
        selenium.find_element(:xpath, "#{txtFBEmail}").send_keys VALID_CREDENTIALS_Facebook[:user]
        wait.until { selenium.find_element(:xpath, "#{txtFBPassword}") }
        sleep(5)
        selenium.find_element(:xpath, "#{txtFBPassword}").click
        sleep(5)
        selenium.find_element(:xpath, "#{txtFBPassword}").send_keys VALID_CREDENTIALS_Facebook[:password]
        wait.until { selenium.find_element(:xpath, "#{btnFBLogin}") }
        selenium.find_element(:xpath, "#{btnFBLogin}").click
        sleep(WAIT_SCREENLOAD)
        wait.until { selenium.find_element(:xpath, "#{btnFBConfirm}") }
        selenium.find_element(:xpath, "#{btnFBConfirm}").click
        sleep(WAIT_SCREENLOAD)
    end
end
Given(/^I login to facebook through safari$/) do
    selenium_new.start_driver
    sleep(SLEEP_SCREENLOAD)
    selenium_new.back()
    sleep(SLEEP_SCREENLOAD)
    wait = Selenium::WebDriver::Wait.new(:timeout => MAX_TIMEOUT) # seconds
    wait.until { selenium_new.find_element(:name, "email") }
    selenium.find_element(:name, "email").send_keys VALID_CREDENTIALS_Facebook[:user]
    wait.until { selenium_new.find_element(:name, "pass") }
    selenium.find_element(:name, "pass").send_keys VALID_CREDENTIALS_Facebook[:password]
    wait.until { selenium_new.find_element(:name, "login") }
    selenium_new.find_element(:name, "login").click
    sleep(SLEEP_SCREENLOAD)
    wait = Selenium::WebDriver::Wait.new(:timeout => SOCIALMEDIA_TIMEOUT) # seconds
    sleep(SLEEP_SCREENLOAD)
    wait.until { selenium_new.find_element(:name, "__CONFIRM__") }
    selenium_new.find_element(:name, "__CONFIRM__").click
    sleep(SLEEP_SCREENLOAD)
end
