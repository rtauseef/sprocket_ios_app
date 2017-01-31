require_relative '../common_library/support/gistfile'

Then(/^I change the language$/) do

    
    #if ENV['LANGUAGE'] == "English"
            #ios_locale_id = "en_US"
    if ENV['LANGUAGE'] == "Spanish"
            ios_locale_id = "es_ES"
    else 
        if ENV['LANGUAGE'] == "French"
                ios_locale_id = "fr_FR"
        else 
            if ENV['LANGUAGE'] == "Chinese"
                ios_locale_id = "zh_Hans"
            else 
                if ENV['LANGUAGE'] == 'German'
                    ios_locale_id = "de_DE"
                else
                    if ENV['LANGUAGE'] == 'French'
                        ios_locale_id = "fr_FR"
                    else 
                        if ENV['LANGUAGE'] == 'Italian'
                            ios_locale_id = "it_IT"
                        else
                            if ENV['LANGUAGE'] == 'Dutch'
                                ios_locale_id = "nl_NL"
                            else
                                if ENV['LANGUAGE'] == 'Danish'
                                    ios_locale_id = "da_DK"
                                else
                                    if ENV['LANGUAGE'] == 'Finnish'
                                        ios_locale_id = "fi_FI"
                                    else
                                        if ENV['LANGUAGE'] == 'Estonian'
                                            ios_locale_id = "et_EE"
                                        else
                                            if ENV['LANGUAGE'] == 'Latvian'
                                                ios_locale_id = "lv_LV"
                                            else
                                                if ENV['LANGUAGE'] == 'Lithuanian'
                                                    ios_locale_id = "lt_LT"
                                                else
                                                    if ENV['LANGUAGE'] == 'Norwegian'
                                                        ios_locale_id = "nb_NO"
                                                    else
                                                        if ENV['LANGUAGE'] == 'Portuguese'
                                                            ios_locale_id = "pt_PT"
                                                        else
                                                            if ENV['LANGUAGE'] == 'Swedish'
                                                                ios_locale_id = "sv_SE"
                                                            else
                                                                ios_locale_id = "en_US"
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
                    end
                end
            end
        end
end
    device_name = get_device_name
    device_type = get_device_type
    sim_name = get_device_name + " " + device_type
    os_version = get_os_version.to_s.gsub(".", "-")
    SimLocale.new.change_sim_locale "#{os_version}","#{sim_name}","#{ios_locale_id}"
    if $curr_language.strip == "es"
        $list_loc=$language_arr["es_ES"]
    else
        if $curr_language.strip == "zh"
             $list_loc=$language_arr["zh_Hans"]
        else 
            if $curr_language.strip == "de"
                $list_loc=$language_arr["de_DE"]
            else
                if $curr_language.strip == "fr"
                    $list_loc=$language_arr["fr_FR"]
                else
                    if $curr_language.strip == "it"
                        $list_loc=$language_arr["it_IT"]
                    else
                        if $curr_language.strip == "nl"
                            $list_loc=$language_arr["nl_NL"]
                        else
                            if $curr_language.strip == "da"
                                $list_loc=$language_arr["da_DK"]
                            else
                                if $curr_language.strip == "fi"
                                    $list_loc=$language_arr["fi_FI"]
                                else
                                    if $curr_language.strip == "et"
                                        $list_loc=$language_arr["et_EE"]
                                    else
                                        if $curr_language.strip == "lv"
                                            $list_loc=$language_arr["lv_LV"]
                                        else
                                            if $curr_language.strip == "lt"
                                                $list_loc=$language_arr["lt_LT"]
                                            else
                                                if $curr_language.strip == "nb"
                                                    $list_loc=$language_arr["nb_NO"]
                                                else
                                                    if $curr_language.strip == "pt"
                                                        $list_loc=$language_arr["pt_PT"]
                                                    else
                                                        if $curr_language.strip == "sv"
                                                            $list_loc=$language_arr["sv_SE"]
                                                        else
                                                            $list_loc=$language_arr["en_US"]
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
                end
            end
        end
    end
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
                         check_element_exists "view marked:'#{$list_loc[item]}'"
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
 