require 'securerandom'

Then(/^I touch the Camera Roll button$/) do
  wait_for_elements_exist("button marked:'Camera Roll'",:timeout=>MAX_TIMEOUT)
  touch "button marked:'Camera Roll'"
end


Then(/^I should see the camera roll albums$/) do
  sleep(WAIT_SCREENLOAD)
  check_element_exists("view marked:'Camera Roll Albums'")
end

Then(/^I touch Camera Roll Image$/) do
  sleep(WAIT_SCREENLOAD)
  wait_for_elements_exist("HPPRSelectAlbumTableViewCell",:timeout=>MAX_TIMEOUT)
  touch "HPPRSelectAlbumTableViewCell"
end


Then(/^I should see the camera roll photos$/) do
  check_element_exists("navigationBar label marked:'Camera Roll Photos'")
end

When(/^I touch a photos in Camera Roll photos$/) do
  sleep(STEP_PAUSE)
  touch "UIImageView index:4"
end

Then(/^I should see the No Wi\-Fi connection$/) do
  sleep(WAIT_SCREENLOAD)
  check_element_exists("view marked:'No Wi-Fi connection'")
end

When(/^I touch the navigation back to Sidemenu$/) do
  wait_for_elements_exist("view marked:'Back'",:timeout=>MAX_TIMEOUT)
  touch("view marked:'Back'")
    sleep(WAIT_SCREENLOAD)
    if $product_id == "Select Template" 
        if element_does_not_exist("view marked:'My Photos'")
            wait_for_elements_exist("view marked:'HPPRBack.png'",:timeout=>MAX_TIMEOUT)
            touch("view marked:'HPPRBack.png'")
        end
    else if $product_id == "Card Editor"
        touch("view marked:'Back'")
    else
    end
    end
  sleep(WAIT_SCREENLOAD)
  wait_for_elements_exist("view marked:'Hamburger'",:timeout=>MAX_TIMEOUT)
  touch("view marked:'Hamburger'")
  sleep(WAIT_SCREENLOAD)
end

Then(/^I should see the selected template name$/) do
  check_element_exists("view marked:'#{$selected_template}'")
  sleep(STEP_PAUSE)
end

Then(/^I verify the Print Queue Count is "(.*?)"$/) do |count|
  count_value = query("UILabel",:text)[1]
  raise "Wrong print queue count!" unless count_value == count
end


Then(/^I should verify the PrintQueue$/) do
  a = query("view marked:'Hemingway'").count

  if(a==1)
    touch "button marked:'Next'"
    sleep(WAIT_SCREENLOAD)
    check_element_exists("view marked:'Print'")

  else if(a==2)
         touch "button marked:'Select All'"
         touch "button marked:'Next'"
         sleep(WAIT_SCREENLOAD)
         check_element_exists("view marked:'Print both'")

       else
         touch "button marked:'Select All'"
         touch "button marked:'Next'"
         sleep(WAIT_SCREENLOAD)
         check_element_exists("view marked:'Print all #{a}'")

       end
  end
end
Then(/^I verify template name and date displayed$/) do
  sleep(WAIT_SCREENLOAD)
  date_value=query( "label {text CONTAINS '#{$current_date}'}", :text)[0].to_s
  template_value=query("UITextView text:'#{$selected_template}'")
  raise "Date not found in correct format!" unless date_value.length > 0
  raise "Template name not found!" unless template_value.length > 0
end
Given(/^I modify the template name as "(.*?)"$/) do |template_name_edited|
  sleep(WAIT_SCREENLOAD)
  $selected_template=template_name_edited
  touch ("UITextView")
  clear_text("UITextView")
  wait_for_keyboard
  template_name_edited.to_s
  keyboard_enter_text("#{template_name_edited}")
  sleep(STEP_PAUSE)
end

Then(/^I verify modified template name displayed on Print Queue screen$/) do
  template_name_displayed=query("view marked:'#{$selected_template}'")
  raise "Edited template name not displayed!" unless template_name_displayed.length > 0
  sleep(STEP_PAUSE)
end

Then(/^I check "(.*?)" button "(.*?)"$/) do |button_name, state|
  if button_name == "Delete"
    check_element_exists("button marked:'Delete'")
    button_value=query("button marked:'Delete'",:isEnabled).first
    if state == "Disabled"
      raise "Delete Button not disabled!" unless button_value == 0
    else
      raise "Delete Button not enabled!" unless button_value == 1
    end
  else if button_name == "Next"
         check_element_exists("button marked:'Next'")
         button_value=query("button marked:'Next'",:isEnabled).first
         if state == "Disabled"
           raise "Delete Button not disabled!" unless button_value == 0
         else
           raise "Delete Button not enabled!" unless button_value == 1
         end
       else if button_name == "Done"
              check_element_exists("button marked:'Done'")
            else if button_name == "Check Box"
                   sleep(WAIT_SCREENLOAD)
                   if state == "Checked"
                       check_element_exists("* id:'MPActiveCircle'")
                   else
                     check_element_exists("* id:'MPInactiveCircle'")
                   end

                 else if button_name == "Unselect All"
                        check_element_exists("button marked:'Unselect All'")
                      else if button_name == "Select All"
                             check_element_exists("button marked:'Select All'")
                           else
                             raise "Invalid argument!"
                           end
                      end
                 end
            end
       end
  end
end
Then(/^I "(.*?)" a job$/) do |action|
  if action== "Select"
    touch query("* id:'MPInactiveCircle'")[0]
    $selected_job_count=job_value=query("tableViewCell child UIImageView id:'MPActiveCircle'").length
      $selected_name=query("UIImageView id:'MPActiveCircle' parent tableViewCell child tableViewCellContentView child label",:text)[0]
     
  else
    touch query("* id:'MPActiveCircle'")[0]
  end
end

Then(/^I verify warning message displayed$/) do
    $print_queue_action = "Delete"
  check_element_exists("label marked:'Delete Print from Print Queue'")
end
Then(/^I check selected job is deleted$/) do
  job_value=query("tableViewCell child UIImageView id:'HPPActiveCircle'").length
  raise "#{job_count} jobs are not deleted!" unless job_value.to_i == $selected_job_count - 1
end

Then(/^I verify "(.*?)" jobs "(.*?)"$/) do |job_count,flag|
  if flag == "Selected"
    job_value=query("tableViewCell child UIImageView id:'MPActiveCircle'").length
    raise "#{job_count} jobs are not selected!" unless job_value == job_count.to_i
  else
    job_value=query("tableViewCell child UIImageView id:'MPInactiveCircle'").length
    raise "#{job_count} jobs are selected!" unless job_value == job_count.to_i
  end
end

Then(/^I should see the added item$/) do
    check_element_exists("view marked:'From Share (extended)'")
end
Then(/^I modify the name$/) do
    $random_name = get_random_name
        touch ("UITextField")
        clear_text("UITextField")
        wait_for_keyboard
        keyboard_enter_text("#{$random_name}")
        sleep(STEP_PAUSE)
        tap_keyboard_action_key
        $item_name=$random_name
        $name_array.push $item_name
end
Then(/^I verify names displayed in Print Queue screen$/) do
    $name_array.each do |item|
    name_displayed=query("view marked:'#{item}'")
    raise "Edited template name not displayed!" unless name_displayed.length > 0
end
        
    
end
Then(/^I check selected job name is deleted$/) do
 template_name_displayed=query("view marked:'#{$selected_name}'")
  raise "Template not deleted!" unless template_name_displayed.length == 0
end


Then(/^I add "(.*?)" job to print queue$/) do |arg1|
while arg1.to_i > 0
    if $product_id == "PrintPod"
		macro %Q|I touch "Share Item"|
		macro %Q|I touch "4x6 portrait"|
		macro %Q|I touch Print Queue|
		macro %Q|I wait for some seconds|
		macro %Q|I should see the "Add Print" screen|
		macro %Q|I modify the name|
		macro %Q|I touch "Add to Print Queue"|
		macro %Q|I wait for some seconds|
    else if $product_id == "Select Template" || $product_id =="Camera Roll Select Template"
        macro %Q|I have disconnected wifi|
        macro %Q|I touch Share icon|
        macro %Q|I wait for some seconds|
		macro %Q|I touch Print Queue|
		macro %Q|I wait for some seconds|
		macro %Q|I should see the "Add Print" screen|
		macro %Q|I modify the name|
		macro %Q|I touch "Add to Print Queue"|
		macro %Q|I wait for some seconds|
        macro %Q|I have connected wifi|
        else if $product_id == "Card Editor"
        
         macro %Q|I have disconnected wifi|
        macro %Q|I click on screen if coach marks are present|
        macro %Q|I touch Share icon|
        macro %Q|I touch "Continue"|
        macro %Q|I wait for some seconds|
		macro %Q|I touch Print Queue|
		macro %Q|I wait for some seconds|
		macro %Q|I should see the "Add Print" screen|
		macro %Q|I modify the name|
		macro %Q|I touch "Add to Print Queue"|
		macro %Q|I wait for some seconds|
        macro %Q|I have connected wifi|
        end
    end
    end
    if arg1.to_i > 1
        macro %Q|I touch "Done"|
        end
     
    arg1 = arg1.to_i - 1
    end    
    end
Then(/^I touch "(.*?)" from the popup$/) do |text|
    button_length = query("label marked:'#{text}'")
    if button_length.length > 1
        touch query("label marked:'#{text}'")[1]
    else
        touch query("label marked:'#{text}'")[0]
    end
end