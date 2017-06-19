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
    touch("* text:'#{$list_loc['Sign Out']}'")
end

Then /I should see Instagram "(.*?)" button$/ do |text|
    if ENV['LANGUAGE'] == "Chinese" && text == "Sign Out" || ENV['LANGUAGE'] == "Chinese-Traditional" && text == "Sign Out"
          touch query "UIButton index:1"
          sleep(STEP_PAUSE)
    end
	sleep(STEP_PAUSE)
    
    check_element_exists("button marked:'#{$list_loc[text]}' button index:0")
    sleep(STEP_PAUSE)
end

When /I touch Instagram "(.*?)" button$/ do |text|
    sleep(STEP_PAUSE)
    touch("button marked:'#{$list_loc[text]}' button index:0")
end

When(/^I touch Google "(.*?)" button$/) do |text|
   wait_for_elements_exist("label marked:'#{text}'",:timeout=>SPINNER_TIMEOUT)
    touch("button marked:'#{text}'")
end

Then(/^I should see Google "(.*?)" button$/) do |text|
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

And /^I navigate back$/ do
    touch @current_page.back_button
    sleep(STEP_PAUSE)
end
When(/^I touch hamburger button on navigation bar$/) do
  selenium.find_element(:xpath, "//XCUIElementTypeApplication[1]/XCUIElementTypeWindow[1]/XCUIElementTypeOther[1]/XCUIElementTypeOther[1]/XCUIElementTypeOther[1]/XCUIElementTypeOther[1]/XCUIElementTypeOther[1]/XCUIElementTypeOther[1]/XCUIElementTypeOther[1]/XCUIElementTypeOther[1]/XCUIElementTypeOther[1]/XCUIElementTypeNavigationBar[1]/XCUIElementTypeButton[1]").click
  sleep(SLEEP_SCREENLOAD)
end

When(/^I select "([^"]*)" option$/) do |arg1|
 selenium.find_element(:xpath, "//XCUIElementTypeStaticText[@name='Buy Paper']").click
  sleep(SLEEP_SCREENLOAD)
  sleep(10.0)
end
When(/^I verify the url$/) do
  url_buy_paper= "www8.hp.com/us/en/printers/zink.html"
  xpath_buy_paper ="//XCUIElementTypeApplication[1]/XCUIElementTypeWindow[1]/XCUIElementTypeOther[1]/XCUIElementTypeOther[1]/XCUIElementTypeOther[1]/XCUIElementTypeOther[1]/XCUIElementTypeOther[1]/XCUIElementTypeOther[1]/XCUIElementTypeOther[2]/XCUIElementTypeTextField[1]"
   selenium.find_element(:name,"Address").click
   sleep(SLEEP_SCREENLOAD)
   raise "Incorrect url loaded!" unless selenium.find_element(:xpath,"#{xpath_buy_paper}").value == url_buy_paper.to_s
end
Given(/^I take screenshots of all the screens$/) do
  puts $screen_names.length
  i = 0
  path =File.dirname(__FILE__)
  path = File.join(path, "../screenshots/")
  screenshots_folder = File.expand_path path
  puts "not nil"
  while i < $screen_names.length
    macro %Q|I am on the "#{$screen_names[i]}" screen|
    screen_name = $screen_names[i]
    screen_neme = screen_name.gsub('  ','_')
    puts "screen"
    puts screen_name
    Dir.chdir  screenshots_folder
  screenshot_embed
  sleep(5.0)
  screenshot_name = "screenshot_" + "#{i}"
  File.rename("#{screenshot_name}.png", "#{screen_name}.png")
  i = i + 1
  end
  
end
Given(/^I take screenshot of "([^"]*)" screen$/) do |screen_name|
  path =File.dirname(__FILE__)
  path = File.join(path, "../screenshots/")
  screenshots_folder = File.expand_path path
  unless screenshots_folder.nil? or File.exists?(screenshots_folder)
    FileUtils.mkdir_p(screenshots_folder)
  end
  Dir.chdir  screenshots_folder
  screenshot_embed
  sleep(SLEEP_SCREENLOAD)
  Dir.open(screenshots_folder).each do |file_name|
    name = File.basename(file_name, ".png")
    if name.to_s.include? "screenshot"
      File.rename(file_name, "#{screen_name}.png")
    end
  end
=begin
  if screen_name == "Landing"
    directory = screenshots_folder
    zipfile_name = "/Users/user/LokiProjects/suvarna/dailyrun/sprocket_ios_app/Sprocket/features/screen.zip"
    puts "direct"
    puts directory
    puts zipfile_name

    Zip::ZipFile.open(zipfile_name, Zip::ZipFile::CREATE) do |zipfile|
    Dir[File.join(directory, '*')].each do |file|
    zipfile.add(file.sub(directory, ''), file)
    end
    end
  end
=end 
end

