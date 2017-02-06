require_relative '../support/gistfile'

Then(/^I change the language$/) do
    ios_locale_id, $list_loc = get_ios_locale_id
    device_name = get_device_name
    device_type = get_device_type
    sim_name = get_device_name + " " + device_type
    os_version = get_os_version.to_s.gsub(".", "-")
    SimLocale.new.change_sim_locale "#{os_version}","#{sim_name}","#{ios_locale_id}"
    language_locale =ios_locale_id.split("_")  
    raise "Language not changed!" unless $curr_language.strip == language_locale[0] 
end

Then(/^I open cameraroll$/) do
        
    if element_exists("button marked:'#{$list_loc['photos_button']}'")
        sleep(WAIT_SCREENLOAD)
        touch "button marked:'#{$list_loc['photos_button']}'"
    end
    if element_exists("view marked:'#{$list_loc['auth']}' index:0")
        sleep(WAIT_SCREENLOAD)
        touch("view marked:'#{$list_loc['auth']}' index:0")
    end
    sleep(WAIT_SCREENLOAD)
end

Then(/^I verify photos screen title$/) do
    screen_title=query("view marked:'#{$list_loc['photo_screen']}'")
    raise "not found!" unless screen_title.length > 0
    sleep(WAIT_SCREENLOAD)
end

Then(/^I touch the option "(.*?)"$/) do |option|
    if ENV['LANGUAGE'] == "Italian"
        if option == "How to & Help"
            touch "UITableViewLabel index:2"
        else
            touch ("view marked:'#{$list_loc[option]}'")
            sleep(STEP_PAUSE)
        end
    else
        if ENV['LANGUAGE'] == "French"
            if option == "Reset Sprocket Printer"
                touch ("UILabel index:0")
            else
                if option == "Setup Sprocket Printer"
                    touch ("UILabel index:1")
                else
                    if option == "View User Guide"
                        touch ("UILabel index:2")
                    else
                        touch ("view marked:'#{$list_loc[option]}'")
                        sleep(STEP_PAUSE)
                    end
                end
            end
        else
            touch ("view marked:'#{$list_loc[option]}'")
            sleep(STEP_PAUSE)
        end
    end
end

Then(/^I verify the "(.*?)" text$/) do |text|
    localized_text=query("view marked:'#{$list_loc[text]}'")
    raise "not found!" unless localized_text.length > 0 
end

And(/^I verify the "(.*?)" link$/) do |link|
    if ENV['LANGUAGE'] == "Danish"
        link_text = query("PGTermsAttributedLabel", :text)[0]
        raise "localization failed!" unless link_text == $list_loc['terms_of_service']
    else
        terms_of_service_link=query("view marked:'#{$list_loc['terms_of_service']}'")
        raise "not found!" unless terms_of_service_link.length > 0
        sleep(WAIT_SCREENLOAD)
    end
end

And(/^I should make sure there is no app crash$/) do 
    background_app=query("UIImageView marked:'helpForum'")
    raise "app crash!!" unless background_app.length > 0
end

    
Then /^I should see the below listed (?:.*):$/ do |table|
    check_options_exist table.raw
    sleep(STEP_PAUSE)
end

def check_options_exist item
    if item.kind_of?(Array)
        item.each do |subitem|
            check_options_exist subitem
            end
    else
         if item == "Pitu" || item == "Qzone"
             if ENV['LANGUAGE'] == "Chinese"
                 check_element_exists "view marked:'#{$list_loc[item]}'"
             else
                 puts "#{item} - Applicable only for Chinese language!".blue 
             end
         else
             if item == "Flickr"
                 if ENV['LANGUAGE'] == "Chinese"
                     puts "#{item} - Not Applicable for Chinese language!".blue 
                 else
                     check_element_exists "view marked:'#{$list_loc[item]}'"
                 end
             else
                 if ENV['LANGUAGE'] == "French"
                     if item == "Reset Sprocket Printer" || item == "Setup Sprocket Printer" || item == "View User Guide"
                        if item == "Reset Sprocket Printer"
                            item1 = query("UILabel index:0", :text)[0]
                        else 
                            if item == "Setup Sprocket Printer"
                                item1 = query("UILabel index:1", :text)[0]
                            else
                                item1 = query("UILabel index:2", :text)[0]
                            end
                        end
                            raise "localization failed!" unless item1 == $list_loc[item]
                     end
                 else
                     if ENV['LANGUAGE'] == "Italian"
                        if item == "How to & Help"
                            item1 = query("UITableViewLabel index:2", :text)[0]
                            raise "localization failed!" unless item1 == $list_loc[item]
                        end
                     else
                         if item == "Version"
                             check_element_exists "view {text CONTAINS '#{$list_loc[item]}'}"
                         else
                            check_element_exists "view marked:'#{$list_loc[item]}'"
                         end
                     end
                 end
             end
         end
    end
end

Then /^I touch "(.*?)" option in the screen$/ do |option|
    if option == "sprocket"
        touch "view marked:'#{$list_loc['side_menu']}'" 
        sleep(STEP_PAUSE)
    else
        touch "view marked:'#{$list_loc[option]}'" 
        sleep(STEP_PAUSE)
    end
end
 