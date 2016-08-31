And /^I should see the photos listed on screen$/ do
    sleep(WAIT_SCREENLOAD)
     raise "photos are not being displayed under My photos or My feed" unless @current_page.photos_count!=0
end

When /^I scroll up photos in "(.*?)"$/ do |tab_name|

  touch("button marked:'#{tab_name}'")
  wait_for_none_animating
  @current_page.view_last_photo

sleep(STEP_PAUSE)
end

Then /^I should see new photos added$/ do
  raise "Photos are not being updated after scrolling" unless @current_page.photos_count < @current_page.photos_scroll_count
  sleep(STEP_PAUSE)
end


When /^I touch back button$/ do
  touch("navigationButton first")
  sleep(STEP_PAUSE)
end