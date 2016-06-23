And /^I scroll down until "([^\"]*)" is visible in the list$/ do |printername|
  sleep(STEP_PAUSE)
  if element_does_not_exist("view marked:'Printer'")
      sleep(STEP_PAUSE)
    if element_exists("view marked:'Settings'")
      touch("view marked:'Settings'")
      sleep(STEP_PAUSE)
      #macro %Q|I select the printer "#{printername}"|
        find_printer printername
      sleep(STEP_PAUSE)
      touch("view:'_UINavigationBarBackIndicatorView'")
      sleep(STEP_PAUSE)
    else
      device_type = get_device_type
      if device_type.to_s == '4s'
        scroll("tableView", :"down")
        sleep(3)
        touch("view marked:'Print'")
      else
        touch("view marked:'Print'")
        sleep(STEP_PAUSE)
        #macro %Q|I select the printer "#{printername}"|
        find_printer printername
      end
    end
  else
    sleep(STEP_PAUSE)
    #macro %Q|I select the printer "#{printername}"|
      find_printer printername
  end
end

Then(/^I click print label$/) do
  sleep(WAIT_SCREENLOAD)
  if element_exists("UINavigationItemButtonView")
    touch query("UINavigationItemButtonView")
    sleep(STEP_PAUSE)
  end
  sleep(WAIT_SCREENLOAD)
  wait_for_elements_exist("view marked:'Print'",:timeout=>MAX_TIMEOUT)
  touch("view marked:'Print'")
  sleep(STEP_PAUSE)
end

Then(/^I click print button$/) do
  sleep(WAIT_SCREENLOAD)
  wait_for_elements_exist("view marked:'Print' index:0",:timeout=>MAX_TIMEOUT)
  touch("view marked:'Print' index:0")
  sleep(WAIT_SCREENLOAD)
  if element_exists("label marked:'No, thanks'")
    touch("label marked:'No, thanks'")
  end
  sleep(STEP_PAUSE)
end


Then(/^I click print$/) do
  sleep(WAIT_SCREENLOAD)
  if element_exists("view marked:'Print' index:0")
    touch("view marked:'Print' index:0")
  else
    wait_for_elements_exist("view marked:'Print'",:timeout=>MAX_TIMEOUT)
    touch("view marked:'Print'")
  end
  sleep(WAIT_SCREENLOAD)
  if element_exists("label marked:'No, thanks'")
    touch("label marked:'No, thanks'")
  end
  sleep(STEP_PAUSE)
end

Then(/^I can see printer list$/) do
  sleep(WAIT_SCREENLOAD)
  if element_does_not_exist("view marked:'Select Printer'")
    sleep(WAIT_SCREENLOAD)
    wait_for_elements_exist("view marked:'Printer'",:timeout=>MAX_TIMEOUT)
    touch("view marked:'Printer'")
  else
    sleep(WAIT_SCREENLOAD)
    wait_for_elements_exist("UITableViewLabel text:'Select Printer'",:timeout=>MAX_TIMEOUT)
    touch("UITableViewLabel text:'Select Printer'")
    sleep(WAIT_SCREENLOAD)
  end
end

Then(/^I should see printer details$/) do
  sleep(WAIT_SCREENLOAD)
  if element_exists("label marked:'Settings'")
    touch("label marked:'Settings'")
    sleep(WAIT_SCREENLOAD)
    wait_for_elements_exist("UITableViewLabel text:'Printer'",:timeout=>MAX_TIMEOUT)
    touch("UITableViewLabel text:'Printer'")
  else
    if element_does_not_exist("view marked:'Select Printer'")
      wait_for_elements_exist("view marked:'Print'",:timeout=>MAX_TIMEOUT)
      touch("view marked:'Print'")
      sleep(WAIT_SCREENLOAD)
      wait_for_elements_exist("view marked :'Printer'",:timeout=>MAX_TIMEOUT)
      touch("view marked :'Printer'")
    else
      sleep(WAIT_SCREENLOAD)
      wait_for_elements_exist("UITableViewLabel text:'Select Printer'",:timeout=>MAX_TIMEOUT)
      touch("UITableViewLabel text:'Select Printer'")
      sleep(WAIT_SCREENLOAD)
    end
  end
end

Then(/^I selected my printer "(.*?)"$/) do |printer|
  sleep(WAIT_SCREENLOAD)
  wait_for_elements_exist("UIPrinterTableViewCell text:'#{printer}'",:timeout=>MAX_TIMEOUT)
  touch("UIPrinterTableViewCell text:'#{printer}'")
  sleep(WAIT_SCREENLOAD)



  if element_exists("UINavigationItemButtonView")
    sleep(WAIT_SCREENLOAD)
    wait_for_elements_exist("UINavigationItemButtonView",:timeout=>MAX_TIMEOUT)
    touch query("UINavigationItemButtonView")
    sleep(WAIT_SCREENLOAD)
  end
end

And(/^I selected the printer "(.*?)"$/) do |printer|
  sleep(WAIT_SCREENLOAD)
  wait_for_elements_exist("UIPrinterTableViewCell text:'#{printer}'",:timeout=>MAX_TIMEOUT)
  touch("UIPrinterTableViewCell text:'#{printer}'")
end

Then(/^I click Printer control to see printers list$/) do
  sleep(WAIT_SCREENLOAD)
  if element_does_not_exist("view marked:'Select Printer'")
    wait_for_elements_exist("label marked:'Settings'",:timeout=>MAX_TIMEOUT)
    touch("label marked:'Settings'")
    sleep(WAIT_SCREENLOAD)
    wait_for_elements_exist("UITableViewLabel text:'Printer'",:timeout=>MAX_TIMEOUT)
    touch("UITableViewLabel text:'Printer'")
  else
    sleep(5)
    wait_for_elements_exist("UITableViewLabel text:'Printer'",:timeout=>MAX_TIMEOUT)
    touch("UITableViewLabel text:'Printer'")
  end
  sleep(5)
end

Then (/^I choose print button$/) do
   device_name = get_device_name
  sleep(STEP_PAUSE)
  if element_exists("UINavigationItemButtonView") && get_os_version.to_f >= 8.0

    touch query("UINavigationItemButtonView")
    sleep(STEP_PAUSE)
  end
  sleep(STEP_PAUSE)
  wait_for_elements_exist("view marked:'Print'",:timeout=>MAX_TIMEOUT)
  if get_os_version.to_f < 8.0 && device_name.to_s != 'iPad'
      #if get_os_version.to_f < 8.0 
    if element_exists("view marked:'Print' index:1")
      touch("view marked:'Print' index:1")
    else
      touch("view marked:'Print' index:0")
    end
  else
    touch("view marked:'Print' index:0")
  end

  sleep(STEP_PAUSE)
  if element_exists("label marked:'No, thanks'")
    touch("label marked:'No, thanks'")
  end
  sleep(STEP_PAUSE)
end

Then (/^I touch Print button labeled "(.*?)"$/) do |printbutton_label|

  device_name = get_device_name
  os_version = get_os_version
  sleep(WAIT_SCREENLOAD)
  #if os_version.to_f < 8.0

   # touch "view marked:'Print'"
#  else

    touch("view marked:'#{printbutton_label}'")
 # end
  sleep(STEP_PAUSE)
end

Then(/^I should see printer listings$/) do
  sleep(WAIT_SCREENLOAD)
  if element_does_not_exist("view marked:'Select Printer'")
    sleep(WAIT_SCREENLOAD)
    touch("view marked:'Printer'")
  else
    sleep(WAIT_SCREENLOAD)
    touch("UITableViewLabel text:'Select Printer'")
    sleep(WAIT_SCREENLOAD)
  end
end

When (/^I select the "(.*?)" option$/) do |option|
  sleep(3)
  wait_for_elements_exist("view marked:'#{option}'", :timeout=>60)
  touch("view marked:'#{option}'")
  sleep(3)
end

Then (/^I should see a spinner$/) do
  sleep(STEP_PAUSE)
  wait_for_elements_exist("label marked:'Contacting Printer...'",:timeout=>MAX_TIMEOUT)
end