#When /^I touch second photo$/ do
   #   wait_for_elements_exist(@current_page.second_photo,:timeout=>MAX_TIMEOUT)
  #touch @current_page.second_photo
  #sleep(STEP_PAUSE)
#end

Then /^the template "(.*?)" should be selected$/ do |template_name|
   if element_exists("view marked:'OverlayView'")
    touch("view marked:'OverlayView'")
    sleep(STEP_PAUSE)
  end
  selected_template = @current_page.selected_template
    
  if selected_template.nil?
    raise "No template selected. Expected: '#{template_name}'"
  end

  unless selected_template.eql? template_name
    raise "Wrong template selected. Expected: '#{template_name}'; Found: '#{selected_template}'"
  end

  sleep(STEP_PAUSE)
end

When /^I touch the "(.*?)" template$/ do |template_name|
  arg=template_name.to_s
  $prev_temp.replace(arg)
  check_elements_exist template_name
  touch("label marked:'#{template_name}'")
  sleep(WAIT_SCREENLOAD)
end
Then /^the previous template should be selected$/ do

   @current_page.selected_template==$prev_temp
  sleep(STEP_PAUSE)
    
end


Then /^I should see the image with "(.*?)" template applied$/ do |template_name|
    @current_page.selected_template==template_name
    sleep(STEP_PAUSE)
end

Then /^I should see coach marks$/ do
    coach_mark = query("view marked:'OverlayView'")
    raise "No coach marks" if coach_mark == ""
    sleep(STEP_PAUSE)
end


Then /^I should see the image with new template applied$/ do
  @current_page.selected_template!="Hemingway"
  sleep(STEP_PAUSE)
end

Then /^I should see like and comment on photo$/ do
  like_value=query("view marked:'likes'",:text)[0]
    raise "No like count" if like_value == ""
  comment_value=query("view marked:'comments'",:text)[0]
    raise "No comment count" if comment_value == ""
  sleep(STEP_PAUSE)
end


Then /^I should see the location on photo$/ do
    location_value=query("view marked:'location'",:text)[0]
    raise "Location not added" if location_value == ""
    sleep(STEP_PAUSE)
end

Then /^I should see the date on photo$/ do
    date_value=query("* id:'date'",:text)[0]
    raise "Date not added" if date_value == ""
    sleep(STEP_PAUSE)
end

Then /^I should see the description on photo$/ do
    description_value=query("* id:'description'",:text)[0]
    raise "Description not added" if description_value == "Enter Text"
    sleep(STEP_PAUSE)
end

Then /^I should see the username on photo$/ do
    username_value=query("* id:'username'",:text)[0]
    raise "Username not added" if username_value == ""
    sleep(STEP_PAUSE)
end

#And /^I click on screen if coach marks are present$/ do
   # if element_exists("view marked:'OverlayView'")
    #touch("view marked:'OverlayView'")
    # end
  #sleep(STEP_PAUSE)
#end
