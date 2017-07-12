require 'securerandom'

And(/^I should see the photo with no "(.*?)"$/) do |edit_item|
    if(edit_item == "frame") 
        frame_value=$frame[$frame_id]['value']
        selected_frame_status = query("UIImageView",:accessibilityIdentifier)[8]
    raise "Wrong frame selected!" unless selected_frame_status == nil
    else
        if edit_item == "sticker"
           sticker_value=$sticker[$sticker_tab][$sticker_id]['value']
           selected_sticker_status = query("IMGLYStickerImageView",:accessibilityLabel)[0]
           raise "Sticker present!" unless selected_sticker_status.to_s == ""
        end
    end
end


And(/^I should see the photo with the "(.*?)"$/) do |edit_item|
    if(edit_item == "frame")
        check_element_exists(@current_page.selected_frame)
    else
        if edit_item == "text"
            sleep(STEP_PAUSE)
            txtTemplate= query("IMGLYTextLabel",:text)[0].to_s
            raise "Text not present!" unless txtTemplate = $template_text 
        end
    end
end

Given(/^I am on the "(.*?)" screen for "(.*?)"$/) do |screen_name, photo_source|
    if photo_source == "Instagram Preview"
        macro %Q|I am on the "Instagram Preview" screen|
    else 
        if photo_source == "Google Preview"
            macro %Q|I am on the "Google Preview" screen|
        else
            macro %Q|I am on the "CameraRoll Preview" screen|        
        end  
    end    
    macro %Q|I touch "Edit"|
    macro %Q|I should see the "Edit" screen|
    if screen_name =="TextEdit"
        macro %Q|I choose "text" option|
        macro %Q|I should see the "TextEdit" screen|
    else
        if screen_name =="FrameEditor"
            macro %Q|I touch "Frame"|
            macro %Q|I should see the "FrameEditor" screen|
		else
			if screen_name =="StickerEditor"
				macro %Q|I touch "Sticker"|
				macro %Q|I should see the "StickerEditor" screen|
			else
				if screen_name =="FilterEditor"
					macro %Q|I touch "Filter"|
					macro %Q|I should see the "FilterEditor" screen|
                else
                    if screen_name =="BrushEditor"
                        macro %Q|I choose "brush" option|
                        macro %Q|I should see the "BrushEditor" screen|
                    end
                        
				end
			end
		end
    end
end
Then(/^I should not see the keyboard view$/) do
  check_element_does_not_exist("UIKBKeyView")
end
Then(/^I verify the filter is selected$/) do
    filter_flag = query("view marked:'Candy'", :isSelected)[0]
    raise "Filter not selected!" unless filter_flag.to_i == 1
  end

Then(/^I should not see the text$/) do
    sleep(STEP_PAUSE)
    txtTemplate= query("IMGLYTextLabel",:text)[0].to_s
    raise "Text found!" unless txtTemplate == ""
end

Then(/^I should see the text with selected "(.*?)"$/) do |option|
    if option == "Font"
        font_arr = query("IMGLYTextLabel",:font)[0]
        font_arr = font_arr.split(" ")
        font_name = font_arr[3].gsub(';','').gsub('"','')
        raise "Incorrect font!" unless font_name.to_s == "Avenir-Heavy"
    else
        if option == "Color"
            txtcolor_arr = query("IMGLYTextLabel",:textColor).first
            raise "Color not applied!" unless txtcolor_arr["red"] < 1 || txtcolor_arr["green"] < 1 || txtcolor_arr["blue"] < 1 
        else
            bgcolor_arr = query("IMGLYTextLabel",:backgroundColor).first
            raise "Color not applied!" unless bgcolor_arr["red"] > 0 || bgcolor_arr["green"] > 0 || bgcolor_arr["blue"] > 0 
        end
    end
end

Then(/^I should see the "(.*?)" image$/) do |option|
    post_photo_frame_height = query("GLKView").first["frame"]["height"]
    post_photo_frame_width = query("GLKView").first["frame"]["width"]
    if option == "cropped"
        if $crop_option == "3:2"
            raise "Image is not cropped!" unless post_photo_frame_height < $curr_edit_img_frame_height
        else
            if $crop_option == "2:3"
                raise "Image is not cropped!" unless post_photo_frame_width > $curr_edit_img_frame_width
            end
        end
    else
        raise "Image is cropped!" unless post_photo_frame_height == $curr_edit_img_frame_height
    end    
end

Then(/^I modify the crop area$/) do
    $curr_bot_lft_crp_x= query("view marked:'Bottom left cropping handle'").first["rect"]["x"]
    $curr_bot_lft_crp_y= query("view marked:'Bottom left cropping handle'").first["rect"]["y"]
    swipe :down,query: "view marked:'Bottom left cropping handle'",force: :strong   
end

Then(/^I verify the modified crop area$/) do
    post_bot_lft_crp_x= query("view marked:'Bottom left cropping handle'").first["rect"]["x"]
    post_bot_lft_crp_y= query("view marked:'Bottom left cropping handle'").first["rect"]["y"] 
    raise "crop area not modified successfully!" unless $curr_bot_lft_crp_x != post_bot_lft_crp_x && $curr_bot_lft_crp_y != post_bot_lft_crp_y
end

 
Then(/^I select "(.*?)" frame$/) do |frame_id|
    sleep(STEP_PAUSE)
    $frame_id = frame_id
    $frame_name=$frame[frame_id]['name']
    select_frame $frame_name
    sleep(STEP_PAUSE)
end

Then(/^I select "(.*?)" sticker$/) do |sticker_id|
    sleep(STEP_PAUSE)
    $sticker_id = sticker_id
    sticker_name=$sticker[$sticker_tab][sticker_id]['name']
    select_sticker sticker_name
    sleep(WAIT_SCREENLOAD)
end
Then(/^I select "(.*?)" font$/) do |font_id|
    sleep(STEP_PAUSE)
    $font_id = font_id
    font_name=$font[font_id]['name']
    select_font font_name
    sleep(STEP_PAUSE)
end
Then(/^I select "([^"]*)" tab$/) do |sticker_tab|
    sleep(STEP_PAUSE)
    $sticker_tab = sticker_tab
    if $sticker_tab == "Fathers Day Category"
        tab = query("IMGLYIconBorderedCollectionViewCell index:2",:accessibilityLabel)[0]
        if tab == "Father's Day Category"
            touch query "IMGLYIconBorderedCollectionViewCell index:2" 
        else
            raise "Tab not found"
        end
    else
        if (element_exists "view marked:'#{sticker_tab.to_s}'")
            touch query("view marked:'#{sticker_tab}'")
            sleep(STEP_PAUSE)
        else
            while element_does_not_exist("view marked:'Add Custom Sticker'")
                scroll("UICollectionView",:left)
            end
            if (element_exists "view marked:'#{sticker_tab.to_s}'")
                touch query("view marked:'#{sticker_tab}'")
            else
                i = 0
                while i < 5 do      
                    scroll("UICollectionView",:right)
                    sleep(WAIT_SCREENLOAD)
                    i = i + 1
                    if i >= 5
                        raise "Tab not found"
                    end
                    if (element_exists "view marked:'#{sticker_tab.to_s}'")
                        touch query("view marked:'#{sticker_tab}'")
                        sleep(STEP_PAUSE)
                        break
                     end
                end
            end
        end
    end
end

Then(/^I select "(.*?)" color$/) do |color_name|
    sleep(STEP_PAUSE)
    select_color color_name
    sleep(STEP_PAUSE)
end

Then(/^I should see the photo with the "(.*?)" frame$/) do |frame_id|
    frame_value=$frame[frame_id]['value']
    selected_frame_status = query("* id:'#{frame_value}'")
    raise "Wrong frame selected!" unless selected_frame_status.length > 0
end

Then(/^I should see the photo with the "(.*?)" font$/) do |font_id|
    font_value=$font[font_id]['value']
    font_name_applied = query("IMGLYTextLabel",:font)[0].split(" ")[3].gsub(';','').gsub('"','')
    raise "Wrong font selected!" unless font_name_applied.to_s == font_value
end

Then(/^I should see the photo with the "(.*?)" color$/) do |color_name|
    $list_loc_red=$edit_screen_arr["edit_color_red"]
    $list_loc_blue=$edit_screen_arr["edit_color_blue"]
    $list_loc_green=$edit_screen_arr["edit_color_green"]
    if $option == "colors"
        color_name_applied_red = query("IMGLYTextLabel",:textColor)[0]["red"] 
        color_name_applied_blue = query("IMGLYTextLabel",:textColor)[0]["blue"] 
        color_name_applied_green = query("IMGLYTextLabel",:textColor)[0]["green"] 
    else
        color_name_applied_red = query("IMGLYTextLabel",:backgroundColor)[0]["red"] 
        color_name_applied_blue = query("IMGLYTextLabel",:backgroundColor)[0]["blue"] 
        color_name_applied_green = query("IMGLYTextLabel",:backgroundColor)[0]["green"] 
    end
    raise "Wrong color selected!" unless color_name_applied_red == $list_loc_red[color_name] && color_name_applied_blue == $list_loc_blue[color_name] && color_name_applied_green == $list_loc_green[color_name]
end

Then(/^I verify that all the "(.*?)" are applied successfully$/) do |option|
   sleep(WAIT_SCREENLOAD)
    color_name=["White", "Gray", "Black", "Light blue", "Blue", "Purple", "Orchid", "Pink", "Red", "Orange", "Gold", "Yellow", "Olive", "Green", "Aquamarin"]
    i = 0
    if option == "frames"
        while i < 19
            frame_id = "frame_"+"#{i}"
            macro %Q|I select "#{frame_id}" frame|
            macro %Q|I choose "save" option|
            macro %Q|I should see the "Edit" screen|
            macro %Q|I should see the photo with the "#{frame_id}" frame|
            macro %Q|I choose "frame" option|
            macro %Q|I should see the "FrameEditor" screen|
            i= i + 1
            sleep(SLEEP_SCREENLOAD)
        end
    else
        if option == "fonts"
            while i < 20
                 font_id = "font_"+"#{i}"
                macro %Q|I select "#{font_id}" font|
                macro %Q|I should see the photo with the "#{font_id}" font|
                i= i + 1
            end
        else
            if option == "colors" || option == "Background colors"
                while i < 15                    
                    $option = option
                    macro %Q|I select "#{color_name[i]}" color|
                    if $sticker_tab != nil
                        macro %Q|I should see the "sticker" with "#{color_name[i]}" Color|
                    else
                        macro %Q|I should see the photo with the "#{color_name[i]}" color|
                    end
                    i= i + 1
                end
            else
                stic_count=$sticker[$sticker_tab].length
                while i < stic_count
		            sticker_id = "sticker_"+"#{i}"
                    macro %Q|I select "#{sticker_id}" sticker|
                    sleep(STEP_PAUSE)
                    macro %Q|I am on the "StickerOptionEditor" screen|
                    macro %Q|I should see the photo with the "#{sticker_id}" sticker from "#{$sticker_tab}" tab|
                    macro %Q|I touch "Delete"|
                    macro %Q|I should see the "Edit" screen|
                    macro %Q|I touch "Sticker"|
                    macro %Q|I should see the "StickerEditor" screen|
                    i= i + 1
                    sleep(SLEEP_SCREENLOAD)
                end
            end
        end 
    end
end

Then(/^I should see the all the corresponding "([^"]*)"$/) do |item|
    check_sticker_exists item
 end
Then(/^I should see the "([^"]*)" with "([^"]*)" Color$/) do |type, color|
  description = query("IMGLYStickerImageView", :description)[0]
  selected_flag = query("view marked:'#{color}'", :isSelected).first
  raise "#{color} no selected!" unless  (description.include? "tintColor") && (selected_flag == 1)
end

Given(/^I should see the photo with the "([^"]*)" sticker from "([^"]*)" tab$/) do |sticker_id, sticker_tab|
    flag = 0
    sticker_value=$sticker[sticker_tab][sticker_id]['value']
    $stic_arr = query("IMGLYStickerImageView",:accessibilityLabel)
    $stic_arr.each do |item|
        if item == sticker_value
            flag = 1
            break
        end
    end
    raise "Wrong sticker selected!" unless flag == 1
end       
Then(/^I could see "([^"]*)" option$/) do |option|
    i = 0
    method_name = option
    if (element_exists "view marked:'#{method_name}'")
        check_element_exists "view marked:'#{method_name}'"
    else
        case 
        when method_name == "brush" || "crop" ||"text" 
            while element_does_not_exist(@current_page.send(method_name))
                sleep(STEP_PAUSE)
                scroll("UICollectionView",:right)
                sleep(STEP_PAUSE)
                i = i + 1 
                break if i == 3
            end
        end
        check_element_exists @current_page.send(method_name)
    end
    sleep(STEP_PAUSE)
end
Given(/^I choose "([^"]*)" option$/) do |option|
    i = 0
    method_name = option
    case 
    when method_name == "brush" || "crop" ||"text" 
        while element_does_not_exist(@current_page.send(method_name))
            scroll("UICollectionView",:right)
            sleep(STEP_PAUSE)
            i = i + 1 
            break if i == 3
        end
    end
    touch @current_page.send(method_name)
    sleep(STEP_PAUSE)
end
Then(/^I select "(.*?)"$/) do |option|
    method_name = option
    $crop_option = ""
    case 
    when option == "2:3" || option == "3:2"
       $crop_option = option
        sleep(2.0)
        touch query("view marked:'#{option}'")
    end
    if $crop_option == ""
        if (element_exists "view marked:'#{method_name}'")
            touch query("view marked:'#{method_name}'")
        else
            touch @current_page.send(method_name)
        end
    end
    sleep(STEP_PAUSE)
end
Then(/^I set the value for "([^"]*)"$/) do |method_name|
    $slider_val = @current_page.send(method_name)
    $slider_val = $slider_val.round(2)
    query("view:'imglyKit.TooltipSlider'",{setValue:$slider_val})
    sleep(STEP_PAUSE) 
end

Then(/^I verify the slider value$/) do 
    value = query("view:'imglyKit.TooltipSlider'",:value)[0]
    value = value.round(2)
   
  raise "Slider value not set correctly!" unless value.to_f == $slider_val.to_f
end

Then(/^I select a sticker from "([^"]*)"$/) do |sticker_tab|
    $stic_id = select_rand_stic sticker_tab
    macro %Q|I select "#{sticker_tab}" tab|
    macro %Q|I select "#{$stic_id}" sticker|
    macro %Q|I am on the "StickerOptionEditor" screen|
end

Then(/^I should see the photo with the sticker from "([^"]*)" tab$/) do |sticker_tab|
    $sticker_tab = sticker_tab
    macro %Q|I should see the photo with the "#{$stic_id}" sticker from "#{$sticker_tab}" tab|
end