Then(/^I should see the message to pair the device with the bluetooth printer$/) do
    check_element_exists @current_page.message_title
    sleep(STEP_PAUSE)
end

And(/^I should see the modal screen title$/) do
    check_element_exists @current_page.modal_title
    sleep(STEP_PAUSE)
end

And(/^I should see the modal screen content$/) do
    check_element_exists @current_page.modal_content
    sleep(STEP_PAUSE)
end

And(/^I should see the button "(.*?)"$/) do |button|
    check_element_exists("label {text CONTAINS '#{button}'}")
    sleep(STEP_PAUSE)
end

And(/^I tap the "OK" button$/) do
    touch "label {text CONTAINS 'OK'}"
    sleep(STEP_PAUSE)
end

Then(/^I should not see the modal screen$/) do
    check_element_does_not_exist @current_page.modal_title
    sleep(STEP_PAUSE)
end

And(/^I should see the list of two printers conneceted$/) do
    
    printer_count = query("UITableViewCell").length
    raise "Printers not listed!" unless printer_count == 2
    $printer1 = query("UITableViewCell index:0", :text)[0]
    $printer2 = query("UITableViewCell index:1", :text)[0]
   
end    

Then(/^I tap the Printer$/) do
    sleep(3)
    printer_name = ENV['printer']
    wait_for_elements_exist("UITableViewCell text:'#{printer_name}'",:timeout=>MAX_TIMEOUT)
    touch("UITableViewCell text:'#{printer_name}'")
    sleep(3)
    $printer_name = printer_name
end

And(/^I check the screen title with the corresponding printer name$/) do 
    title = query("label {text CONTAINS 'HP sprocket'}", :text)[0]
    raise "wrong title!" unless $printer_name = title 
end

And(/^I check "(.*?)" field displays its value$/) do |field|
    if field == "Errors"
        raise "Errors field is empty!" if @current_page.errors.nil?
    else
        if field == "Battery Status"
            raise "Battery Status field is empty!" if @current_page.battery_status.nil?
        else
            if field == "Auto Off"
                raise "Auto Off field is empty!" if @current_page.auto_off.nil?
            else
                if field == "Mac Address"
                    raise "Mac Address field is empty!" if @current_page.mac_address.nil?
                else
                    if field == "Firmware Version"
                        raise "Firmware Version field is empty!" if @current_page.firmware_version.nil?
                    else
                        raise "Hardware Version field is empty!" if @current_page.hardware_version.nil?
                    end
                end
            end
        end
    end
end
    

Then(/^I verify the selected printer is listed in Recent Printer field$/) do
    $printer_1 = query("UITableViewCell index:0", :text)[0] 
    raise "wrong printer!" unless $printer_name = $printer_1
    
end

Then(/^I verify the second printer is listed in Other Printers field$/) do 
    printer2 = query("UITableViewCell index:1", :text)[0] 
    if $printer_name = $printer_1
        raise "wrong printer!" unless $printer2 = printer2
    else
        raise "wrong printer!" unless $printer1 = printer2
    end
    
end

