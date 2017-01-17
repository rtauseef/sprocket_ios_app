Given /^Side menu is open$/ do
  macro %Q|I touch menu button on navigation bar|
  sleep(STEP_PAUSE)
end

When /^I touch menu button on navigation bar$/ do
  touch("UIImageView id:'hamburger'")
  sleep(WAIT_SCREENLOAD)
end

When /^I touch menu button on navigation bar,twice$/ do
  macro %Q|I touch menu button on navigation bar|
  sleep(STEP_PAUSE)
  macro %Q|I touch menu button on navigation bar|
  sleep(STEP_PAUSE)
end

When /^I open the side menu$/ do
  macro %Q|I touch menu button on navigation bar|
  sleep(STEP_PAUSE)
end

Then /^I should see the side menu$/ do
    sleep(WAIT_SCREENLOAD)
    check_element_exists("view marked:'#{$list_loc['side_menu']}'")
    sleep(STEP_PAUSE)
end

Then /^I should see the user's profile pic/ do
    sleep(WAIT_SCREENLOAD)
       if element_exists("PGSwipeCoachMarksView")
         sleep(STEP_PAUSE)
         a = send_uia_command :command => "target.rect().size.width"
         send_uia_command :command => "target.dragFromToForDuration({x:50.00, y:200.00}, {x:(#{a['value']}*0.9), y:200.00}, 1)"
         sleep(WAIT_SCREENLOAD)
       end
  sleep(STEP_PAUSE)
  macro %Q|I touch menu button on navigation bar|
     
  check_element_exists("imageView index:6")
  touch("imageView index:6")
  sleep(STEP_PAUSE)
end

Then /^I should not see the side menu$/ do
  check_element_does_not_exist("view marked:'HP Social Media Snapshots'")
  sleep(STEP_PAUSE)
end

Then /^I click Sign Out button on popup$/ do
	sleep(STEP_PAUSE)
    touch("* text:'Sign Out'")
end

Then /I should see Instagram "(.*?)" button$/ do |text|
	sleep(STEP_PAUSE)
    check_element_exists("button marked:'#{text}' button index:0")
    sleep(STEP_PAUSE)
end

When /I touch Instagram "(.*?)" button$/ do |text|
    sleep(STEP_PAUSE)
    touch("button marked:'#{text}' button index:0")
end

When(/^I touch Flickr "(.*?)" button$/) do |text|
   wait_for_elements_exist("label marked:'#{text}'",:timeout=>SPINNER_TIMEOUT)
    touch("button marked:'#{text}'")
end

Then(/^I should see Flickr "(.*?)" button$/) do |text|
    sleep(STEP_PAUSE)
    check_element_exists("button marked:'#{text}' button index:2")
    sleep(STEP_PAUSE)
end

When /^I click close button$/ do
  touch @current_page.close_button
  sleep(STEP_PAUSE)
end

And /^I tap back button$/ do
    touch @current_page.back
    sleep(STEP_PAUSE)
end


