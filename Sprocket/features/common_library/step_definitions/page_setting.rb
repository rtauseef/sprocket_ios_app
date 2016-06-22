And /^I scroll screen "(.*?)"$/ do |direction|
  scroll("tableView", :"#{direction}")
  device_type = get_device_type    
  if device_type.to_s == '4s' || '5'
    sleep(STEP_PAUSE)
    scroll("tableView", :"#{direction}")
  end
  sleep(STEP_PAUSE)
end

Then /^switch should turn ON$/ do
    if get_os_version.to_f < 8.0
        sleep(WAIT_SCREENLOAD)
    else
        query("switch",:isOn)==1
        sleep(STEP_PAUSE)
    end
end

When /^I touch switch$/ do
    if get_os_version.to_f < 8.0
        sleep(WAIT_SCREENLOAD)
    else
        touch("switch")
    end
end

When /^I touch "([^"]*)" and check number of copies is (\d+)$/ do |copies_option,number_of_copies|
  if get_os_version.to_f < 8.0
      #puts "Increment/Decrement option is not available"
      #Do nothing, skip step
  else
    macro %Q|I touch "#{copies_option}"|
    macro %Q|the number of copies is #{number_of_copies}|
  end
end

Then /^The number of copies must be (\d+)$/ do |number_of_copies|
  step "the number of copies is #{number_of_copies}"
  sleep(STEP_PAUSE)
end

And /^the number of copies is (\d+)$/ do |amount|
  if get_os_version.to_f < 8.0
    puts "Increment/Decrement option is not available"
    #Do nothing, skip step
  else
    scroll("tableView", :down)
    sleep(STEP_PAUSE)
    copies = 0
    while (copies =  @current_page.number_of_copies ) < amount.to_i do
      touch @current_page.increment_button
    end
    while (copies =  @current_page.number_of_copies) > amount.to_i do
      touch @current_page.decrement_button
    end
    sleep(STEP_PAUSE)
  end
end

And /^I touch "(.*?)" navigation button$/ do |button_label|
  wait_for_none_animating
  touch("navigationButton marked:'#{button_label}'")
  wait_for_none_animating
end

Then(/^I should see the following:$/) do |table|
  check_item_exist table.raw
  sleep(STEP_PAUSE)
end


Then(/^I should see the paper size options$/) do
  
  if element_does_not_exist("view marked:'Paper Size'")
    sleep(STEP_PAUSE)
    wait_for_elements_exist("label marked:'Settings'",:timeout=>MAX_TIMEOUT)
    touch("label marked:'Settings'")
    sleep(STEP_PAUSE)
    wait_for_elements_exist("view marked:'Paper Size'",:timeout=>MAX_TIMEOUT)
    touch("view marked:'Paper Size'")
  else
    sleep(STEP_PAUSE)
    wait_for_elements_exist("view marked:'Paper Size'",:timeout=>MAX_TIMEOUT)
    touch("view marked:'Paper Size'")
  end
  sleep(STEP_PAUSE)
end

Then(/^I selected the paper size "(.*?)"$/) do |size|
  touch("label marked:'#{size}'")
  $paper_size = size.delete(" ")
    $papersize = size
  #if element_exists("UINavigationItemButtonView")
    #touch query("UINavigationItemButtonView")
   # sleep(STEP_PAUSE)
  #end
  sleep(STEP_PAUSE)
end

And /^I choose "(.*?)"$/ do |paper_size|
    
    sleep(SLEEP_MIN)
    if element_does_not_exist("view marked:'Paper Size'")
        sleep(SLEEP_MIN)
        touch "label marked:'Settings'"
        sleep(SLEEP_MIN)
        touch("view marked:'Paper Size'")
        sleep(SLEEP_MIN)
        touch("view marked:'#{paper_size}'")
        sleep(SLEEP_MIN)
        touch("view:'_UINavigationBarBackIndicatorView'")
    else
        sleep(SLEEP_MIN)
        touch("view marked:'Paper Size'")
        sleep(SLEEP_MIN)
        touch("view marked:'#{paper_size}'")
    end
        
end

Then(/^I should see the paper type options$/) do
  if($papersize == "8.5 x 11")
    sleep(STEP_PAUSE)
    scroll("tableView", :down)
    if element_does_not_exist("view marked:'Paper Size'")
      sleep(STEP_PAUSE)
      wait_for_elements_exist("label marked:'Settings'",:timeout=>MAX_TIMEOUT)
      touch("label marked:'Settings'")
      sleep(STEP_PAUSE)
      wait_for_elements_exist("view marked:'Paper Type'",:timeout=>MAX_TIMEOUT)
      touch("view marked:'Paper Type'")
    else
      sleep(STEP_PAUSE)
      wait_for_elements_exist("view marked:'Paper Type'",:timeout=>MAX_TIMEOUT)
      touch("view marked:'Paper Type'")
    end
    sleep(STEP_PAUSE)
  end
end

Then(/^I selected the paper type "(.*?)"$/) do |type|
  if($papersize == "8.5 x 11")
    $paper_type = type.delete(" ")
    sleep(STEP_PAUSE)
    wait_for_elements_exist("label marked:'#{type}'",:timeout=>MAX_TIMEOUT)
    touch("label marked:'#{type}'")
    if element_exists("UINavigationItemButtonView")
      #touch query("UINavigationItemButtonView")
      sleep(STEP_PAUSE)
    end
      sleep(STEP_PAUSE)
  end
end

Then(/^I should see the Print Instructions$/) do
   sleep(SLEEP_MIN)
    check_element_exists("navigationBar marked:'Print Instructions'")
end

Then(/^I load "(.*?)" job to page settings$/) do |job_count|
  if job_count != "1"
      
       macro %Q|I touch "Select All"|
    end
     macro %Q|I touch "Next"|
end