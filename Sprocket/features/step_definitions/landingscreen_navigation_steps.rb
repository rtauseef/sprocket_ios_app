Given(/^I am on the instagram login screen$/) do
res = query("imageView marked:'Instagram'")
end

Then /^I touch the next page control$/ do
  xcoord = query("pageControl child view index:3").first["rect"]["x"]
  ycenter = query("pageControl child view index:3").first["rect"]["center_y"]
  touch(nil, :offset => {:x => xcoord-5.to_i, :y => ycenter.to_i})
  end
 
Then /^I should navigate to facebook screen$/ do
    
res = query("imageView marked:'Facebook'")
 end

Then /^I should navigate to Flickr photos screen$/ do
res1 = query("imageView marked:'Flickr'")
end

Then /^I should navigate to Social Media Snapshots screen$/ do
res2 = query("view marked:'CameraRoll'")
 end

Then /^I touch the previous page control$/ do
  xcoord = query("pageControl child view index:2").first["rect"]["x"]
  ycenter = query("pageControl child view index:2").first["rect"]["center_y"]
  touch(nil, :offset => {:x => xcoord-5.to_i, :y => ycenter.to_i})
end

Then /^I should navigate to print queue screen$/ do
res3 = query("view marked:'Print Queue'")
end

Then /^I swipe to see "(.*?)" screen$/ do |screen_name|
    if ENV['LANGUAGE'] == "Chinese" || ENV['LANGUAGE'] == "Chinese-Traditional"
        if screen_name == "Flickr"
            puts "#{screen_name} - Not Applicable for Chinese language!".blue
        else
            swipe(:left)
           # check_element_exists("UINavigationBar marked:'#{$list_loc[screen_name]}")
            check_element_exists("view marked:'#{$list_loc[screen_name]}")
            sleep(STEP_PAUSE)
        end
    else
        if screen_name == "Camera Roll"
            i = 0
            while i < 3
                swipe(:left)
                sleep(WAIT_SCREENLOAD)
                i = i + 1
            end
            #check_element_exists("UINavigationBar marked:'#{$list_loc[screen_name]}")
            check_element_exists("view marked:'#{$list_loc[screen_name]}")
            sleep(STEP_PAUSE)
        else
            if screen_name == "Flickr"
                sleep(STEP_PAUSE)
                swipe(:right)
                #check_element_exists("UINavigationBar marked:'#{$list_loc['flickr']}'")
                check_element_exists("view marked:'#{$list_loc['flickr']}'")
                sleep(STEP_PAUSE)
            else
                if screen_name == "facebook"
                    swipe(:right)
                   # check_element_exists("UINavigationBar marked:'#{$list_loc[screen_name]}'")
                    check_element_exists("view marked:'#{$list_loc[screen_name]}'")
                else
                    puts "#{screen_name} - Applicable only for Chinese language!".blue 
                end
            end
        end
    end
end