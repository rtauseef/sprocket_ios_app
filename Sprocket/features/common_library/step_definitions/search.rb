When /^I enter hashtag$/ do
  touch("button marked:'Hashtag'")
  sleep(WAIT_SCREENLOAD)
  keyboard_enter_text("#healthy")
  sleep(STEP_PAUSE)
end

Then /^I should see results$/ do
    sleep(STEP_PAUSE)
    check_element_exists("tableViewCell")
    sleep(STEP_PAUSE)
end

And /^click on first result$/ do
  sleep(STEP_PAUSE)
  wait_for_elements_exist("tableViewCell index:0",:timeout=>MAX_TIMEOUT)
  touch("tableViewCell index:0")
  sleep(STEP_PAUSE)
end

When /^I enter username$/ do
  touch("button marked:'Users'")
  sleep(STEP_PAUSE)
  keyboard_enter_text("healthysmoothie")
  sleep(STEP_PAUSE)
end

And /^I touch search icon$/ do
  touch("view marked:'HPPRSearch'")
end