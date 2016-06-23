#Reference- print_confirm_simulator is renamed to print_metrics
require 'json'
require 'open-uri'

Then (/^I run print simulator$/) do
  start_print_simulator
  sleep(STEP_PAUSE)
end

Then (/^Fetch metrics details$/) do
    sleep(SLEEP_SCREENLOAD)
    
    if $product_id == "PrintPod"
        
	   #hash = `curl -x "http://proxy.atlanta.hp.com:8080" -L "http://hpmobileprint:print1t@print-metrics-test.twosmiles.com/api/v1/mobile_app_metrics?product_name="MobilePrintSDK-cal"&&print_library_version=#{$print_library_version}"`
        hash = `curl -L "http://hpmobileprint:print1t@print-metrics-test.twosmiles.com/api/v1/mobile_app_metrics?product_name="MobilePrintSDK-cal"&&print_library_version=#{$print_library_version}"`
        hash = JSON.parse(hash)
        $mertics_array = hash["metrics"]
       
        if $print_queue_action == "Delete" || $print_queue_action == "Print"
            puts "loop#{$print_queue_action}"
            $mertics_details = hash["metrics"][$mertics_array.length - 1]
        else
            
            $mertics_details = hash["metrics"][0]
         end
    else   
    #    hash = `curl -x "http://proxy.atlanta.hp.com:8080" -L "http://hpmobileprint:print1t@print-metrics-test.twosmiles.com/api/v1/mobile_app_metrics?template_text=#{$template_text}"`
   hash = `curl -L "http://hpmobileprint:print1t@print-metrics-test.twosmiles.com/api/v1/mobile_app_metrics?template_text=#{$template_text}"`
    hash = JSON.parse(hash)
    $mertics_details = hash["metrics"][0] 
  end
    end

And (/^I check the paper size is "([^\"]*)"$/) do |size|
  $papersize = size
  compare  = ($mertics_details['paper_size'] == size) ?  true : false
  raise "paper size verification failed" unless compare==true
end

And (/^I check the product name is "([^\"]*)"$/) do |product_name|
  compare  = ($mertics_details['product_name'] == product_name) ?  true : false
  raise "product name verification failed" unless compare==true

end

And (/^I check the device brand is "([^\"]*)"$/) do |device_brand|
  compare  = ($mertics_details['device_brand'] == device_brand) ?  true : false
  raise "device brand verification failed" unless compare==true
end

And (/^I check the off ramp is "([^\"]*)"$/) do |off_ramp|
  compare  = ($mertics_details['off_ramp'] == off_ramp) ?  true : false
  raise "off ramp verification failed" unless compare==true
end

And (/^I check the photo source is "([^\"]*)"$/) do |photo_source|
  compare  = ($mertics_details['photo_source'] == photo_source) ?  true : false
  raise "photo source verification failed" unless compare==true
end

And (/^I check the device type is "([^\"]*)"$/) do |device_type|
  compare  = ($mertics_details['device_type'] == device_type) ?  true : false
  raise "device type verification failed" unless compare==true
end

And (/^I check the os version$/) do
  compare  = ($mertics_details['os_version'].strip == get_os_version.strip) ?  true : false
  raise "os version verification failed" unless compare==true
end

And (/^I check the font$/) do
    compare  = ($mertics_details["font"] == $font_name) ?  true : false
    raise "font name verification failed" unless compare==true
end

And (/^I check the font size$/) do
    compare  = ($mertics_details["font_size"] == $font_size.to_s) ?  true : false
    raise "font size verification failed" unless compare==true
end

And (/^I check the font color$/) do    
    compare  = ($mertics_details["font_color"] == $text_color) ?  true : false
    raise "font color verification failed" unless compare==true
end

And (/^I check the category$/) do
    compare  = ($mertics_details["category"] == $category) ?  true : false
    raise "category name verification failed" unless compare==true
end

And (/^I check the message type is "([^\"]*)"$/) do |message_type|
    compare  = ($mertics_details["message_type"] == message_type) ?  true : false
    raise "message_type verification failed" unless compare==true
end

And (/^I check the paper type is "([^\"]*)"$/) do |type|
  #   if($papersize == "8.5 x 11")
  compare  = ($mertics_details['paper_type'] == type) ?  true : false
  raise "paper type verification failed" unless compare==true
  #      else
  #  sleep(3)
  #     end
end


And (/^I check the number of copies is "([^\"]*)"$/) do |copies|
 #$papersize = size
  compare = ($mertics_details['copies'] == copies) ?  true : false
  raise "Number of copies verification failed" unless compare==true
end

And (/^I check the manufacturer is "([^\"]*)"$/) do |manufacturer|
  compare  = ($mertics_details['manufacturer'] == manufacturer) ?  true : false
  raise "manufacturer verification failed" unless compare==true
end

And (/^I check the os_type is "([^\"]*)"$/) do |os_type|
  compare  = ($mertics_details['os_type'] == os_type) ?  true : false
  raise "os_type verification failed" unless compare==true
end

And (/^I check the version$/) do
   if $product_id == "PrintPod"
        compare  = ($mertics_details['version'].strip == "1.0 (" + $version + ")".strip) ?  true : false
    else
         compare  = ("Version" + " " + $mertics_details['version'].strip == $version.strip) ?  true : false
    end
    raise "version verification failed" unless compare==true
end

And (/^I check black_and_white_filter value is "([^\"]*)"$/) do |filter_value|
  compare  = ($mertics_details['black_and_white_filter'] == filter_value) ?  true : false
  raise "black_and_white_filter verification failed" unless compare==true
end


And (/^I check the printer_location$/) do
    $metrics_type= $mertics_details['app_type']
    $pcname = gethostname
    if get_os_version.to_f < 8.0
        compare  = ($mertics_details['printer_location'] == "Not Available") ?  true : false
        raise "printer_location verification failed" unless compare==true
    else
      if $metrics_type == 'Partner'
        compare  = ($mertics_details['printer_location'] == "Not Collected") ?  true : false
        raise "printer_location verification failed" unless compare==true
      else
        compare  = ($mertics_details['printer_location'].strip == $pcname.strip || "Not Provided") ?  true : false
        raise "printer_location verification failed" unless compare==true
      end
    end
end


And (/^I check the printer_model is "([^\"]*)"$/) do |printer_model|
    $printer_model = printer_model
   
    if printer_model == "No Print"
        
      compare  = ($mertics_details['printer_model'] == "No Print") ?  true : false
      raise "printer_model verification failed" unless compare==true
    else
    if get_os_version.to_f < 8.0
        compare  = ($mertics_details['printer_model'].strip == "Not Available") ?  true : false
        raise "printer_model verification failed" unless compare==true
    else 
       printermodel = $printer_model + " " + "Printer"
        compare  = ($mertics_details['printer_model'].strip == printermodel||"Not Provided" ) ?  true : false
        raise "printer_model verification failed" unless compare==true
    end
    end
end



And (/^I check the printer_name$/) do
    $printer_name = $printer_model + " " + "@" + " " + $pcname
    $metrics_type = $mertics_details['app_type']
    if get_os_version.to_f < 8.0 
        compare  = ($mertics_details['printer_name'] == "Not Available") ?  true : false
        raise "printer_name verification failed" unless compare==true
    else
      if $metrics_type == 'Partner'
        compare  = ($mertics_details['printer_name'] == "Not Collected") ?  true : false
        raise "printer_name verification failed" unless compare==true
      else
        compare  = ($mertics_details['printer_name'].strip == $printer_name.strip) ?  true : false
        raise "printer_name verification failed" unless compare==true
      end
    end
end

And (/^I check the image_url$/) do
  compare = ($mertics_details['image_url'] != "No Photo") ?  true : false
  raise "image_url verification failed" unless compare==true
end

And (/^I check the image_url is "([^\"]*)"$/) do |image_url|
    compare = ($mertics_details['image_url'] == image_url) ?  true : false
  raise "image_url verification failed" unless compare==true
end

And (/^I check the photo_source is "([^\"]*)"$/) do |photo_source|
  compare = ($mertics_details['photo_source'] == photo_source) ?  true : false
  raise "photo_source verification failed" unless compare==true
end

And (/^I check the template name$/) do
    compare = ($mertics_details['template_name'] == $card_name) ?  true : false 
    raise "template_name verification failed" unless compare==true
end

And (/^I check the template name is "([^\"]*)"$/) do |template_name|
    $template_name=template_name
  compare = ($mertics_details['template_name'] == template_name) ?  true : false
  raise "template_name verification failed" unless compare==true
end

And (/^I check the template text$/) do

  values_first=$template_text[0..17]
  values_second=$template_text[19..22]
  values_hash_first=$mertics_details['template_text'][0..17]
  values_hash_second=$mertics_details['template_text'][19..22]
  if values_first!= values_hash_first||values_second!= values_hash_second
    raise "template_text verification failed"
  end
end

And (/^I check the template_text_edited is "([^\"]*)"$/) do |template_text_edited|
  compare = ($mertics_details['template_text_edited'] == template_text_edited) ?  true : false
  raise "template_text_edited verification failed" unless compare==true
end

And (/^I check the user_id is "([^\"]*)"$/) do |user_id|
  compare = ($mertics_details['user_id'] == user_id) ?  true : false
  raise "user_id verification failed" unless compare==true
end

And (/^I check the user_name on photo$/) do
  compare = ($mertics_details['user_name'] == $username_value) ?  true : false
  raise "user_name verification failed" unless compare==true
end

And (/^I check the user_name on photo is "([^\"]*)"$/) do |user_name|
    compare = ($mertics_details['user_name'] == user_name) ?  true : false 
    raise "user_name verification failed" unless compare==true
end

And (/^I check the photo_location on photo$/) do
  compare = ($mertics_details['photo_location'] == $location_value) ?  true : false
  raise "photo_location verification failed" unless compare==true
end

And (/^I check the photo_location_edited is "([^\"]*)"$/) do |photo_location_edited|
  compare = ($mertics_details['photo_location_edited'] == photo_location_edited) ?  true : false
  raise "photo_location_edited verification failed" unless compare==true
end

And (/^I delete printer simulater generated files$/) do
  getfiles = remove_files
  if getfiles.empty? #=> true
    raise "Deleting printer simulater generated failed"
  end
end

And (/^I check the template_text eliminates special characters and enters rest of the text$/) do
    macro %Q|I check the template text|
    sleep(STEP_PAUSE)
end

And /^I get first card name$/ do
  sleep(WAIT_SCREENLOAD)
  $card_name=first_from query("label index:0", :text)
end

And (/^I get the printer_name$/) do
    sleep(WAIT_SCREENLOAD)
    if element_exists ("view marked:'Printer'")
        $print_queue_action = "Print"
        $printer_name=query("UITableViewLabel index:3",:text)[0]
        
    else
        wait_for_elements_exist("view marked:'Settings'",:timeout=>MAX_TIMEOUT)
        touch query("view marked:'Settings'")
        sleep(WAIT_SCREENLOAD)
        macro %Q|I should see the "Print Settings" screen|
        $printer_name=@current_page.selected_printer_name
        touch("view:'_UINavigationBarBackIndicatorView'")
        sleep(STEP_PAUSE)
    end
     
end

Then (/^I get the username and photo_location on photo$/) do
  sleep(WAIT_SCREENLOAD)
  $username_value=@current_page.user_name
  $location_value=@current_page.photo_location
  sleep(STEP_PAUSE)
end

And /^I get filter,font,font size,font color$/ do
    screen_name = "Cards List"
    required_page = page_by_name(screen_name)
    #wait_for{required_page.current_page? }
    @current_page = required_page
  $filter= @current_page.select_filter
  $font_name= @current_page.select_font
  $font_size= @current_page.font_size
  $text_color= @current_page.message_text_color
  $text_message = @current_page.message_text

end
Then(/^I "(.*?)" Unique ID per app$/) do |state|
    $state =state
  if state == "Disabled"
       touch query("UITableViewCellContentView * text:'Use unique ID per app' sibling UISwitch")
      end
end

Then(/^I get the device id$/) do
    if $product_id == "PrintPod"
        if $state == "Disabled"
            $device_id = first_from query "UITableViewLabel marked:'Unmodified Device ID' sibling label", :text
        else            
			$device_id = first_from query "UITableViewLabel marked:'Reported ID (per app)' sibling label", :text
        end
    end
end

Then(/^I verify metrics not generated for current print/) do
    previous_metrics_length=$mertics_array.length
    macro %Q|Fetch metrics details|
    if previous_metrics_length < $mertics_array.length
        raise "Print metrics generated for without metrics option"
    end
end

Then(/^I enter custom library version$/) do
	touch ("UITextField")
    clear_text("UITextField")
    wait_for_keyboard
    $print_library_version = get_random_name
    keyboard_enter_text("#{$print_library_version}")
    sleep(STEP_PAUSE)
    query "textField isFirstResponder:1", :resignFirstResponder
end

Then(/^I check the library version$/) do
     if $product_id != "PrintPod"
    #if $product_id == "Home" || $product_id == "CameraRollPhotos"
            $print_library_version = "3.0.7"
     end
    compare = ($mertics_details['print_library_version'] == $print_library_version) ?  true : false
	raise "print_library_version verification failed" unless compare==true
end

Then(/^I check the product id is "(.*?)"$/) do |product_id| 
  compare = ($mertics_details['product_id'] == product_id) ?  true : false
  raise "product_id verification failed" unless compare==true
end

Then(/^I check the application type is "(.*?)"$/) do |app_type|
   compare = ($mertics_details['app_type'] == app_type) ?  true : false
  raise "app_type verification failed" unless compare==true
end

Then(/^I check the route taken is "(.*?)"$/) do |route_taken|
   compare = ($mertics_details['route_taken'] == route_taken) ?  true : false
  raise "Route_taken verification failed!" unless compare==true
end
Then(/^I check the template position$/) do 
  $template_position_array=

{
    "position_value" => {
        "Hemingway" => "0",
        "Kerouac" => "1",
        "Asimov" => "2",
        "Lovecraft"=> "3",
        "Wallace" => "4",
        "Ariel" => "5",
        "Sofia" => "6",
        "Jack"=> "7",
        "Steinbeck" => "8",
        "Dickens" => "9",
        "Clean"=> "10"
        }
    }
    
   compare = ($mertics_details['template_position'] == $template_position_array["position_value"]["#{$template_name}"]) ?  true : false
  raise "Template position verification failed!" unless compare==true
end
Then(/^I check the content type is "(.*?)"$/) do |content_type|
   compare = ($mertics_details['content_type'] == content_type) ?  true : false
  raise "Content type verification failed!" unless compare==true
end
Then(/^I check the device id$/) do
   compare = ($mertics_details['device_id'] == $device_id) ?  true : false
  raise "Device_id verification failed!" unless compare==true
end

Then(/^I check the wifi ssid$/) do
    compare = ($mertics_details['wifi_ssid'] == "22DDD1D57CAD99CCF3A956FCAA38C887") ?  true : false
    raise "Wifi-ssid verification failed!" unless compare==true
end

