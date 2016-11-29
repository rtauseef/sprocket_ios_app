require_relative '../common_library/support/gistfile'

Then(/^I change language$/) do
    device_name = get_device_name
    device_type = get_device_type
    sim_name = get_device_name + " " + device_type
    os_version = get_os_version.to_s.gsub(".", "-")
    SimLocale.new.change_sim_locale "#{os_version}","#{sim_name}","es_ES"
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


    
$language_arr =

{
    "en_US" => {
        "photos_button" => "Camera Roll",
        "auth" => "Authorize",
        "album_screen" => "Camera Roll Albums",
        "photo_screen"=> "Camera Roll Photos"
        },
    "es_ES" => {
        "photos_button" => "Fotos",
        "auth" => "Autorizar",
        #"album_screen" => "Albumes de Fotos",
        #"photo_screen"=> "Fotos de Fotos"
        "photo_screen"=> "Camera Roll"
        }
    }
    

