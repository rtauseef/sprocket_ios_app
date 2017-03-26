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
    if option == "How to & Help"
        if ENV['LANGUAGE'] == "Italian"
        
            touch "UITableViewLabel index:2"
        else
            touch ("view marked:'#{$list_loc[option]}'")
            sleep(STEP_PAUSE)
        end
    else
        if ENV['LANGUAGE'] == "French" || ENV['LANGUAGE'] == "Canada-French"
            if option == "Reset Sprocket Printer"
                touch ("UILabel index:0")
            else
                if option == "Setup Sprocket Printer"
                    touch ("UILabel index:1")
                else
                    if option == "View User Guide"
                        touch ("UILabel index:2")
                    else
                        if option == "Messenger Support"
                            puts "#{option} - Not Applicable for #{ENV['LANGUAGE']}!".blue
                        else
                            touch ("view marked:'#{$list_loc[option]}'")
                            sleep(STEP_PAUSE)
                        end
                    end
                end
            end
        else
            if option == "Messenger Support"
                if ENV['LANGUAGE'] == "Mexico-English" || ENV['LANGUAGE'] == "Canada-English" || ENV['LANGUAGE'] == "English-US"
                
                    touch ("view marked:'#{$list_loc[option]}'")
                else
                    puts "#{option} - Not Applicable for #{ENV['LANGUAGE']}!".blue
                end
            else
				sleep(STEP_PAUSE)
                touch ("view marked:'#{$list_loc[option]}'")
                sleep(STEP_PAUSE)
            end
        end
    end
end

Then(/^I verify the "(.*?)" text$/) do |text|
    localized_text=query("view marked:'#{$list_loc[text]}'")
    raise "not found!" unless localized_text.length > 0 
end


And(/^I verify the Terms of Service link for "(.*?)"$/) do |social_media|
    sleep(STEP_PAUSE)
    if social_media == "Instagram"
        if ENV['LANGUAGE'] == "Danish"
          link_text = query("PGTermsAttributedLabel", :text)[0] 
          raise "localization failed!" unless link_text == $list_loc['terms_of_service_instagram']
        else
           terms_of_service_link=query("view marked:'#{$list_loc['terms_of_service_instagram']}'")
        raise "not found!" unless terms_of_service_link.length > 0
        sleep(STEP_PAUSE)
        end
    else
        if social_media == "Camera Roll"
            if ENV['LANGUAGE'] == "Danish"
                link_text = query("PGTermsAttributedLabel", :text)[0] 
                raise "localization failed!" unless link_text == $list_loc['terms_of_service_cameraroll']
            else
                terms_of_service_link=query("view marked:'#{$list_loc['terms_of_service_cameraroll']}'")
                raise "not found!" unless terms_of_service_link.length > 0
                sleep(STEP_PAUSE)
            end
        else
            if social_media == "facebook"
                if ENV['LANGUAGE'] == "Danish"
                    link_text = query("PGTermsAttributedLabel", :text)[0] 
                    raise "localization failed!" unless link_text == $list_loc['terms_of_service_facebook']
                else
                    terms_of_service_link=query("view marked:'#{$list_loc['terms_of_service_facebook']}'")
                    raise "not found!" unless terms_of_service_link.length > 0
                end
                     sleep(STEP_PAUSE)
            else
                if social_media == "Flickr"
                    sleep(STEP_PAUSE)
                    if ENV['LANGUAGE'] == "Chinese" || ENV['LANGUAGE'] == "Chinese-Traditional"
                        puts "#{social_media} - Not Applicable for Chinese language!".blue
                    else
                        if ENV['LANGUAGE'] == "Danish"
                            link_text = query("PGTermsAttributedLabel", :text)[0] 
                            raise "localization failed!" unless link_text == $list_loc['terms_of_service_flickr']
                        else
                            terms_of_service_link=query("view marked:'#{$list_loc['terms_of_service_flickr']}'")
                            raise "not found!" unless terms_of_service_link.length > 0
                            sleep(STEP_PAUSE)
                        end
                    end
                else
                    if social_media == "QZone"
                        if ENV['LANGUAGE'] == "Chinese" || ENV['LANGUAGE'] == "Chinese-Traditional"
                            terms_of_service_link=query("view marked:'#{$list_loc['terms_of_service_Qzone']}'")
                            raise "not found!" unless terms_of_service_link.length > 0
                            sleep(STEP_PAUSE)
                        else
                            puts "#{social_media} - Applicable only for Chinese language!".blue
                            sleep(STEP_PAUSE)
                        end
                    else
                        if social_media == "pitu"
                            if ENV['LANGUAGE'] == "Chinese" || ENV['LANGUAGE'] == "Chinese-Traditional"
                                terms_of_service_link=query("view marked:'#{$list_loc['terms_of_service_pitu']}'")
                                raise "not found!" unless terms_of_service_link.length > 0
                                sleep(STEP_PAUSE)
                            else
                                puts "#{social_media} - Applicable only for Chinese language!".blue
                            end
                        end
                    end
                end
            end
        end
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
             if ENV['LANGUAGE'] == "Chinese" || ENV['LANGUAGE'] == "Chinese-Traditional"
                 check_element_exists "view marked:'#{$list_loc[item]}'"
             else
                 puts "#{item} - Applicable only for Chinese language!".blue 
             end
         else
             if item == "Flickr"
                 if ENV['LANGUAGE'] == "Chinese" || ENV['LANGUAGE'] == "Chinese-Traditional"
                     puts "#{item} - Not Applicable for Chinese language!".blue 
                 else
                     check_element_exists "view marked:'#{$list_loc[item]}'"
                 end
             else
                if item == "Reset Sprocket Printer" || item == "Setup Sprocket Printer" || item == "View User Guide"
                    if ENV['LANGUAGE'] == "French" || ENV['LANGUAGE'] == "Canada-French"
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
                     if item == "How to & Help"
                        if ENV['LANGUAGE'] == "Italian"
                        
                            item1 = query("UITableViewLabel index:2", :text)[0]
                            raise "localization failed!" unless item1 == $list_loc[item]
                        end
                     else
                         if item == "Version"
                             check_element_exists "view {text CONTAINS '#{$list_loc[item]}'}"
                         else
                             if item == "Terms and service"
                                if ENV['LANGUAGE'] == "Danish"
                                     link_text = query("PGTermsAttributedLabel", :text)[0] 
                                     raise "localization failed!" unless link_text == $list_loc[item]
                                 end
                             else
                                 if item == "Print to sprocket"
                                    if ENV['LANGUAGE'] == "Turkish"
                                    
                                        item_text = query("UILabel index:3", :text)[0]
                                        raise "localization failed!" unless item_text == $list_loc[item]
                                    end
                                else
                                     if item == "Messenger Support"
                                         if ENV['LANGUAGE'] == "Mexico-English" || ENV['LANGUAGE'] == "Canada-English" || ENV['LANGUAGE'] == "English-US"
                                             check_element_exists "view marked:'#{$list_loc[item]}'"
                                         else
                                             puts "#{item} - Not Applicable for #{ENV['LANGUAGE']}!".blue
                                         end
                                     else
                                        check_element_exists "view marked:'#{$list_loc[item]}'"
                                     end
                                 end
                             end
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

Then /^I should see the popup message for the "(.*?)"$/ do |option|
    if option == "camera access"
        if ENV['LANGUAGE'] == "French" || ENV['LANGUAGE'] == "Canada-French"
            title_name = query("UILabel index:1", :text)[0]
            raise "localization failed!" unless title_name == $list_loc['camera_access']
        else
            check_element_exists "view marked:'#{$list_loc['camera_access']}'"
        end
        sleep(STEP_PAUSE)
    else
        check_element_exists "view marked:'#{$list_loc['Save_to_CameraRoll']}'"
        sleep(STEP_PAUSE)
    end
end

Then /^I verify the "(.*?)" of the popup message for "(.*?)"$/ do |option, button|
    if button == "cameraLanding"
        if option == "title"
            if ENV['LANGUAGE'] == "French" || ENV['LANGUAGE'] == "Canada-French"
                title_name = query("UILabel index:1", :text)[0]
                raise "localization failed!" unless title_name == $list_loc['camera_access']
            else
                check_element_exists "view marked:'#{$list_loc['camera_access']}'"
            end
        else
            check_element_exists "view marked:'#{$list_loc['camera_access_content']}'"
        end
    else
        if button == "DownloadButton"
            if option == "title"
               sleep(STEP_PAUSE) 
            else
                sleep(STEP_PAUSE) 
            end
        else
             if option == "title"
               sleep(STEP_PAUSE) 
            else
                sleep(STEP_PAUSE) 
            end
        end
    end
end

Then /^I verify the "(.*?)" button text$/ do |button|
    check_element_exists "view marked:'#{$list_loc['Edit']}'"
    sleep(STEP_PAUSE)
end
 