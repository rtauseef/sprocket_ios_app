Given /^I fill the form with valid Instagram credentials$/ do
    sleep(WAIT_SCREENLOAD)
    social_media="webView css:'h1' {textContent LIKE 'Instagram'}"
    check_page_loaded social_media
  @current_page.fill_input_field(VALID_CREDENTIALS[:user],0)
  sleep(SLEEP_MIN)
  #@current_page.password_input = VALID_CREDENTIALS[:password]
  @current_page.fill_input_field(VALID_CREDENTIALS[:password],1)

  sleep(STEP_PAUSE)
end

Then(/^I wait for some time$/) do
  sleep(WAIT_SCREENLOAD)
end

Given /^I fill the form with valid flicker credentials/ do
  sleep(WAIT_SCREENLOAD)
  social_media="webView css:'#login-username'"
  check_page_loaded social_media
  @current_page.fill_input_field(VALID_CREDENTIALS_Flickr[:user],0)
  sleep(SLEEP_MIN)
  touch("webView css:'#login-signin'")
  sleep(WAIT_SCREENLOAD)
  @current_page.fill_input_field(VALID_CREDENTIALS_Flickr[:password],1)
  sleep(STEP_PAUSE)
end

When /^I touch Instagram Log in button$/ do
 touch @current_page.instagram_login_button
    sleep(WAIT_SCREENLOAD)
    if element_exists("webView css:'input' index:1")
        #puts "-Authorizing..."
        touch instagram_auth_button
    end
  sleep(STEP_PAUSE)
end

When /^I touch Flicker Log in button$/ do
    device_name = get_device_name
    if device_name != "iPad"
        touch query("label marked:'Done'")
    end
  touch ("webView css:'#login-signin'")
  sleep(SLEEP_SCREENLOAD)
  scroll("webView", :down)
  wait_for_elements_exist("webView css:'#auth-allow'", :timeout => MAX_TIMEOUT)
  sleep(STEP_PAUSE)
  touch("webView css:'#auth-allow'")
  sleep(WAIT_SCREENLOAD)
  end
  
  
 Then(/^I select Instagram logo$/) do
    touch "view marked:'LoginInstagram.png'"
    sleep(STEP_PAUSE)
   swipe_coach_marks_view
end