
Then /^I wait for sometime$/ do
sleep(SLEEP_SCREENLOAD) 
end    

Then(/^I should see the HP Store page$/) do
  sleep(SLEEP_SCREENLOAD) 
selenium.back()
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
    camera_pop_up = "//UIAApplication[1]/UIAWindow[1]/UIAAlert[1]/UIACollectionView[1]/UIACollectionCell[1]/UIAButton[1]"
    if selenium.find_elements(:xpath,"#{camera_pop_up}").size > 0
        selenium.find_elements(:xpath,"#{camera_pop_up}").click
    end
    raise "Wrong screen!" unless (selenium.find_elements(:xpath,"//UIAStaticText[@value='sprocket']").size) > 0
end

Then(/^I should see the "(.*?)" Logo$/) do |photo_source|
    sleep(2.0)
  if photo_source == "Facebook"
        value = "//UIAApplication[1]/UIAWindow[1]/UIAButton[4]"
    end
    raise "#{photo_source} logo not found!" unless (selenium.find_elements(:xpath,"#{value}").size) > 0
end
Then(/^I touch the "(.*?)" Logo$/) do |photo_source|
    
  if photo_source == "Facebook"
        value = "//UIAApplication[1]/UIAWindow[1]/UIAButton[4]"
    end
    selenium.find_element(:xpath,"#{value}").click
end

When(/^I touch signin button$/) do
        sleep(WAIT_SCREENLOAD)
        action = Appium::TouchAction.new
        action.swipe start_x: 50,end_x: 300,start_y: 100,end_y: 100,duration: 1000
        action.perform 
        sleep(WAIT_SCREENLOAD)
    sign_in_button="//UIAApplication[1]/UIAWindow[1]/UIAElement[1]/UIAScrollView[1]/UIAButton[1]"
    if selenium.find_elements(:xpath,"#{sign_in_button}").size > 0
        selenium.find_element(:xpath,"#{sign_in_button}").click
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
        txtFBEmail="//UIAApplication[1]/UIAWindow[1]/UIAScrollView[1]/UIAWebView[1]/UIATextField[1]"
        #txt_pass= "//UIASecureTextField[@value='Facebook password']"
       txtFBPassword="//UIAApplication[1]/UIAWindow[1]/UIAScrollView[1]/UIAWebView[1]/UIASecureTextField[1]"
      btnFBLogin= "//UIAApplication[1]/UIAWindow[1]/UIAScrollView[1]/UIAWebView[1]/UIAButton[1]"
        btnFBConfirm= "//UIAApplication[1]/UIAWindow[1]/UIAScrollView[1]/UIAWebView[1]/UIAButton[2]"
        wait = Selenium::WebDriver::Wait.new(:timeout => MAX_TIMEOUT) # seconds
        wait.until { selenium.find_element(:xpath,"#{txtFBEmail}") }
        selenium.find_element(:xpath,"#{txtFBEmail}").click
        selenium.find_element(:xpath, "#{txtFBEmail}").send_keys VALID_CREDENTIALS_Facebook[:user]
        wait.until { selenium.find_element(:xpath, "#{txtFBPassword}") }
        sleep(5)
        selenium.find_element(:xpath, "#{txtFBPassword}").click
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