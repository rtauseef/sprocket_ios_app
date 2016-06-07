Given /^I am on the safari screen$/ do
    path =File.expand_path("../../common_library/support/runme.sh", __FILE__)
    #path =File.expand_path("../../support/runme.sh", __FILE__)
system(path)
sleep(SLEEP_MAX)
end

Then /^I wait for facebook login page to open in safari$/ do
sleep(SLEEP_MAX)
end

Then /^I should see the Facebook Albums screen$/ do
wait_for_elements_exist("* id:'Facebook Albums'",:timeout=>MAX_TIMEOUT)
res = query("* id:'Facebook Albums'")
raise "Facebook Albums screen missing!!" unless res.length > 0    
end

Then /^I wait for sometime$/ do
sleep(SLEEP_SCREENLOAD) 
end
    
Then /^I fill the form with valid credentials for facebook$/ do
sleep(SLEEP_SCREENLOAD) 
selenium.navigate.back()
sleep(SLEEP_SCREENLOAD)
wait = Selenium::WebDriver::Wait.new(:timeout => MAX_TIMEOUT) # seconds
wait.until { selenium.find_element(:name, "email") }
selenium.find_element(:name, "email").send_keys VALID_CREDENTIALS_Facebook[:user]
wait.until { selenium.find_element(:name, "pass") }
selenium.find_element(:name, "pass").send_keys VALID_CREDENTIALS_Facebook[:password]
wait.until { selenium.find_element(:name, "login") }
selenium.find_element(:name, "login").click
end

Then /^I click ok in confirm dialog$/ do
    sleep(SLEEP_SCREENLOAD)
    wait = Selenium::WebDriver::Wait.new(:timeout => SOCIALMEDIA_TIMEOUT) # seconds
    sleep(SLEEP_SCREENLOAD)
    wait.until { selenium.find_element(:name, "__CONFIRM__") }
    selenium.find_element(:name, "__CONFIRM__").click
    sleep(WAIT_SCREENLOAD)
    selenium.quit
    sleep(SLEEP_SCREENLOAD)
end
Then(/^I should see the HP Store page$/) do
  sleep(SLEEP_SCREENLOAD) 
selenium.navigate.back()
sleep(SLEEP_SCREENLOAD)
end
