require_relative '../common_library/support/gistfile'

Then(/^I change the language$/) do

    
    if ENV['LANGUAGE'] == "English"
            ios_locale_id = "en_US"
    else if ENV['LANGUAGE'] == "French"
                ios_locale_id = "fr_FR"
    else
         ios_locale_id = "es_ES"
    end
    end
    device_name = get_device_name
    device_type = get_device_type
    sim_name = get_device_name + " " + device_type
    os_version = get_os_version.to_s.gsub(".", "-")
    SimLocale.new.change_sim_locale "#{os_version}","#{sim_name}","#{ios_locale_id}"
    #English-en_US
    #Spanish-es_ES
    if $curr_language.strip == "es"
        $list_loc=$language_arr["es_ES"]
    else 
        $list_loc=$language_arr["en_US"]

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

Then(/^I verify the "(.*?)" text$/) do |text|
    if text == "Take or Select photo"
        select_photo_text=query("view marked:'#{$list_loc['select_photo']}'")
        raise "not found!" unless select_photo_text.length > 0
    else 
        if text == "Buy Paper"
            buy_paper_link=query("view marked:'#{$list_loc['buy_paper']}'")
            raise "not found!" unless buy_paper_link.length > 0
        else
            if text == "How to & Help"
                how_to_help=query("view marked:'#{$list_loc['how_to_help']}'")
                raise "not found!" unless how_to_help.length > 0
            else
                if text == "Give Feedback"
                    give_feedback=query("view marked:'#{$list_loc['give_feedback']}'")
                    raise "not found!" unless give_feedback.length > 0 
                else
                    if text == "Privacy"
                        privacy=query("view marked:'#{$list_loc['privacy']}'")
                        raise "not found!" unless privacy.length > 0
                    else
                        if text == "About"
                            about=query("view marked:'#{$list_loc['about']}'")
                            raise "not found!" unless about.length > 0
                        else
                            if text == "Camera Roll"
                                camera_roll=query("view marked:'#{$list_loc['camera_roll']}'")
                                raise "not found!" unless camera_roll.length > 0
                            else
                                if text == "Sign In"
                                    sign_in=query("view marked:'#{$list_loc['sign_in']}'")
                                    raise "not found!" unless sign_in.length > 0
                                end
                            end
                        end
                    end
                end
            end                                    
        end
    end 
    sleep(WAIT_SCREENLOAD)
end

And(/^I verify the "(.*?)" link$/) do |link|
    terms_of_service_link=query("view marked:'#{$list_loc['terms_of_service']}'")
    raise "not found!" unless terms_of_service_link.length > 0
    sleep(WAIT_SCREENLOAD)
end


    

