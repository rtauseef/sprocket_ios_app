require 'securerandom'

Then (/^I should see "(.*?)" mark$/) do |mark|
    if(mark == "Close")
        check_element_exists(@current_page.close)
    else 
        check_element_exists(@current_page.check)
    end
end

When(/^I tap "(.*?)" mark$/) do |mark|
    if(mark == "Close")
        touch @current_page.close
    else
        if(mark == "Check")
            touch @current_page.check
        else
            if(mark == "Save")
                    touch @current_page.save
                    #sleep(STEP_PAUSE)
            else
                if(mark == "Add text")
                        touch @current_page.add_text
                        #sleep(STEP_PAUSE)
                else
                    if(mark == "Cancel")
                        touch @current_page.cancel
                        #sleep(STEP_PAUSE)
                    end
                end
            end
        end
    end
end


Then (/^I select "(.*?)"$/) do |option|
    if option == "Filter"
        touch @current_page.filter_1
    else 
        if option == "sticker" || option == "frame"
        touch "IMGLYIconCollectionViewCell"
        sleep(STEP_PAUSE)
    else
            sleep(2.0)
            touch query("view marked:'#{option}'")
    end
    end

end



And(/^I should see the photo with no "(.*?)"$/) do |edit_item|
    if(edit_item == "frame") 
        check_element_does_not_exist(@current_page.selected_frame)
    else
        if edit_item == "sticker"
            check_element_does_not_exist(@current_page.selected_sticker)
        end
    end
end


And(/^I should see the photo with the "(.*?)"$/) do |edit_item|
    if(edit_item == "frame")
       
            check_element_exists(@current_page.selected_frame)
    else
        if edit_item == "sticker"
            check_element_exists @current_page.selected_sticker
            sleep(STEP_PAUSE)
    else
        if edit_item == "text"
            sleep(STEP_PAUSE)
            txtTemplate= query("IMGLYTextLabel",:text)[0].to_s
            raise "Text not present!" unless txtTemplate = $template_text 
        end
    end
    end
end

And(/^I verify blue line indicator is displayed under selected frame$/) do 
   width_indicator = query("UIView index:29").first["frame"]["width"]
    raise "Blue line indicator not found!" unless width_indicator==64
end

Given(/^I am on the "(.*?)" screen for "(.*?)"$/) do |screen_name, photo_source|
    if photo_source == "Preview"
        macro %Q|I am on the "Preview" screen|
    else 
        if photo_source == "Flickr Preview"
        macro %Q|I am on the "Flickr Preview" screen|
        else
            macro %Q|I am on the "CameraRoll Preview" screen|        
        end  
    end    
    macro %Q|I tap "Edit" button|
    macro %Q|I should see the "Edit" screen|
    if screen_name =="TextEdit"
        macro %Q|I tap "Text" button|
        macro %Q|I should see the "TextEdit" screen|
    else
        if screen_name =="FrameEditor"
            macro %Q|I tap "Frame" button|
            macro %Q|I should see the "FrameEditor" screen|
		else
			if screen_name =="StickerEditor"
				macro %Q|I tap "Sticker" button|
				macro %Q|I should see the "StickerEditor" screen|
			else
				if screen_name =="FilterEditor"
					macro %Q|I tap "Filter" button|
					macro %Q|I should see the "FilterEditor" screen|
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
    puts txtTemplate
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
    post_photo_frame_width =query("UIImageView index:0").first["frame"]["width"]
    post_photo_frame_height    = query("UIImageView index:0").first["frame"]["height"]
    if option == "cropped"
        raise "Image is not cropped!" unless post_photo_frame_width > $curr_edit_img_frame_width && post_photo_frame_height > $curr_edit_img_frame_height
    else
       raise "Image is cropped!" unless post_photo_frame_width == $curr_edit_img_frame_width && post_photo_frame_height == $curr_edit_img_frame_height
    end    
end
