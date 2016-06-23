require 'emoji_data'

Given /^I am on (?:the?) "(.*?)" screen$/ do |screen_name|
    $product_id=screen_name
    @current_page = page_by_name(screen_name)
    @current_page.navigate
    sleep(STEP_PAUSE)
    $name_array=Array.new
end

=begin
Given /^I am on "(.*?)" screen$/ do |screen_name|
    @current_page = page_by_name(screen_name)
    @current_page.navigate

    sleep(STEP_PAUSE)
end

When(/^I go to "(.*?)" screen$/) do |screen_name|
    macro %Q|I am on "#{screen_name}" screen|
end
=end

Then /^I should see the "(.*?)" screen$/ do |screen_name|
    required_page = page_by_name(screen_name)
    if(screen_name == "Instagram Signin" || screen_name == "FlickrSignin")
        wait_for(:timeout => SOCIALMEDIA_TIMEOUT ){ required_page.current_page?}
    else if (screen_name == "Mail")
        raise "Mail screen not loaded" if required_page.New_message.length <= 0
    else
         wait_for(:timeout => MAX_TIMEOUT ){ required_page.current_page? }
    end
    end
    @current_page = required_page
end

Then /^I should see the "(.*?)" screen in less than "(.*?)" seconds$/ do |screen_name, timeout|
    required_page = page_by_name(screen_name)
    animating_views = "view isAnimating:1"
    wait_for(timeout: 3) { required_page.current_page? and query(animating_views).empty? }
    @current_page = required_page
    sleep(STEP_PAUSE)
end

When /^I do a long swipe to the "(right|left)" direction$/ do |direction|
    reverse_direction = :right
    if direction.eql? "right"
        reverse_direction = :left
    end
    scroll "scrollView", reverse_direction
    #swipe direction
    sleep(STEP_PAUSE)
end

When /^I swipe to the right$/ do
    @scroll_view_first_position = scroll_view_position
    macro %Q|I scroll right|
    sleep(STEP_PAUSE)
end

When /^I enter "(.*?)"$/ do |text|
   #clear_text("* id:'description'")
   # keyboard_enter_char "Delete"
    clear_text("textView")
    sleep(STEP_PAUSE)
    keyboard_enter_text text
    sleep(STEP_PAUSE)
end

Then /^I should see "(.*?)" as the title$/ do |expected_title|
    check_element_exists "navigationBar label marked:'#{expected_title}'"
    sleep(STEP_PAUSE)
end

Then /^I should see the following (?:.*):$/ do |table|
    if element_exists ("navigationBar marked:'Select Template'")
        check_elements_exist table.raw
    else
        check_tables_exist table.raw
  sleep(STEP_PAUSE)
end
    end

When /^I touch "(.*?)" button$/ do |text|
  touch("button marked:'#{text}'")
  sleep(STEP_PAUSE)
end

Then /^I should see the "(.*?)" tab Selected$/ do |tab_name|
  query("button marked:'#{tab_name}'", :isSelected)
  sleep(STEP_PAUSE)
end

When /^I touch "(.*?)" option$/ do |option_type|
  wait_for_elements_exist("tableViewCell label marked:'#{option_type}'", :timeout => MAX_TIMEOUT)
  touch("tableViewCell label marked:'#{option_type}'")
  sleep(STEP_PAUSE)
end

When /^I touch Authorize$/ do
  sleep(WAIT_SCREENLOAD)
  if element_exists("view marked:'Authorize' index:0")
  touch("view marked:'Authorize' index:0")
  end
end
Given(/^I have disconnected wifi$/) do
 %x[networksetup -setairportpower en1 off]
      sleep(5)
end

Given(/^I have connected wifi$/) do
 %x[networksetup -setairportpower en1 on]
    sleep(5)
end

Then (/^I open printer simulator$/) do
  open_print_simulator
end

Then (/^I click load paper$/) do
  click_load_paper
end

And (/^I click paper size sensor of printer "([^\"]*)"$/) do |printer_name|

  click_paper_size_sensors "#{printer_name}"
end

And (/^I get the version$/) do
  sleep(WAIT_SCREENLOAD)
  $version=@current_page.build_version
  sleep(STEP_PAUSE)
end

When /^I enter unique text$/ do
  touch("textView")
  clear_text("textView")
  sleep(WAIT_SCREENLOAD)
  $template_text ="TestAutomation"+(Time.now.inspect.split.join).to_s
  keyboard_enter_text $template_text
end

Then (/^I check whether template is available for given settings$/) do
  template = gettemplate
  if File.exist?(template)
    #puts "Template file found for given print settings"
  else
    raise "No template file found"
  end
end

Then(/^I wait for some seconds$/) do
  sleep(5)
end

And /^I scroll screen to find "([^\"]*)"/ do |label|
  wait_poll(:until_exists => "label text:'#{label}'", :timeout=>MAX_TIMEOUT) do
    scroll("tableView", :down)
  end
  sleep(STEP_PAUSE)
end
And /^I scroll screen up to find "([^\"]*)"/ do |label|
  wait_poll(:until_exists => "label text:'#{label}'", :timeout=>MAX_TIMEOUT) do
    scroll("tableView", :up)
  end
  sleep(STEP_PAUSE)
end

And /^I click on screen if coach marks are present$/ do
	sleep(WAIT_SCREENLOAD)
    if element_exists("view marked:'OverlayView'")
    touch("view marked:'OverlayView'")
     end
  sleep(STEP_PAUSE)
end

When /^I touch grid mode button$/ do
  touch @current_page.grid_mode_button
  sleep(STEP_PAUSE)
end
Then /^I should see the photos in a grid view$/ do
  check_element_exists(@current_page.grid_mode_check_button)
  sleep(STEP_PAUSE)
end
When /^I touch list mode button$/ do
  touch @current_page.list_mode_button
  sleep(STEP_PAUSE)
end

Then /^I should see the photos in list view$/ do
check_element_exists(@current_page.list_mode_check_button)
end



When /^I touch second photo$/ do
      wait_for_elements_exist(@current_page.second_photo,:timeout=>MAX_TIMEOUT)
  touch @current_page.second_photo
  sleep(STEP_PAUSE)
end

When (/^I enter an emoji text$/) do
  touch("textView")
  clear_text("textView")
  wait_for_keyboard
  $template_text = "Emoji"+(Time.now.inspect.split.join).to_s
  keyboard_enter_text $template_text
  sleep(WAIT_SCREENLOAD)
  device_name=get_device_name    
  if element_exists ("tabBarButton marked:'Text'")
      if device_name.to_s != 'iPad' 
        touch("UIKBKeyView index:5")
      else
	    if get_os_version.to_f  < 8.3
          touch("UIKBKeyView index:6")
		else
		  touch("UIKBKeyView index:5")
		end
      end      
  else
      if device_name.to_s != 'iPad' 
        touch("UIKBKeyView index:2")
      else
        touch("UIKBKeyView index:3")
      end
  end
    sleep(WAIT_SCREENLOAD)
        if element_exists("label marked:'OK'")
            touch("label marked:'OK'")
            sleep(WAIT_SCREENLOAD)
        end
      
  sleep(WAIT_SCREENLOAD)
  if get_os_version.to_f > 8.2
    if element_exists ("tabBarButton marked:'Text'")
	  if get_os_version.to_f < 9.2
        touch("UIKBKeyView index:5")
	  end
    else

	  if get_os_version.to_f < 9.2
        touch("UIKBKeyView index:2")
	  end

    end
    sleep(WAIT_SCREENLOAD)
    if element_exists ("tabBarButton marked:'Text'")
	  if get_os_version.to_f < 9.2
        touch query("UILabel index:20")
	  else
	    touch query("UILabel index:19")
	  end
    else

	  if get_os_version.to_f < 9.2
        touch query("UILabel index:22")
	  else 
	    touch query("UILabel index:21")
	  end

    end
  else
    uia('UIATarget.localTarget().frontMostApp().keyboard().keys()[3].tap()')
  end
	sleep(STEP_PAUSE)
    my_string=query("textView",:text).first
    test=EmojiData.scan(my_string)
    raise "emoji is not entered!" unless test.length > 0
    test.each do |ec|
		puts "found some #{ec.short_name}"
    end
end




