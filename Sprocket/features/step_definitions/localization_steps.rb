require_relative '../common_library/support/gistfile'

Then(/^I change the language$/) do

    
    #if ENV['LANGUAGE'] == "English"
            #ios_locale_id = "en_US"
    if ENV['LANGUAGE'] == "Spanish"
            ios_locale_id = "es_ES"
    else if ENV['LANGUAGE'] == "French"
                ios_locale_id = "fr_FR"
    else if ENV['LANGUAGE'] == "Chinese"
                ios_locale_id = "zh_Hans"
    else
         ios_locale_id = "en_US"
    end
    end
end
    device_name = get_device_name
    device_type = get_device_type
    sim_name = get_device_name + " " + device_type
    os_version = get_os_version.to_s.gsub(".", "-")
    SimLocale.new.change_sim_locale "#{os_version}","#{sim_name}","#{ios_locale_id}"
    #English-en_US
    #Spanish-es_ES
    #Chinese-zh_Hans

    if $curr_language.strip == "es"
        $list_loc=$language_arr["es_ES"]
    else
        if $curr_language.strip == "zh"
             $list_loc=$language_arr["zh_Hans"]
        else 
	$list_loc=$language_arr["en_US"]
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
    touch ("view marked:'#{$list_loc[option]}'")
    sleep(STEP_PAUSE)
end

Then(/^I verify the "(.*?)" text$/) do |text|
    localized_text=query("view marked:'#{$list_loc[text]}'")
    raise "not found!" unless localized_text.length > 0 
end

And(/^I verify the "(.*?)" link$/) do |link|
    terms_of_service_link=query("view marked:'#{$list_loc['terms_of_service']}'")
    raise "not found!" unless terms_of_service_link.length > 0
    sleep(WAIT_SCREENLOAD)
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
                 check_element_exists "view marked:'#{$list_loc[item]}'"
             end
         end
    end
end
