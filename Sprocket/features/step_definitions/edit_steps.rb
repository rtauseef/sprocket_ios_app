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
		sleep(STEP_PAUSE)
    else
        if(mark == "Check")
            touch @current_page.check
        else
            if(mark == "Save")
                sleep(WAIT_SCREENLOAD)
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
        if option == "sticker" 
            sticker_name="v_xoxo_TN"
            select_sticker sticker_name
            sleep(STEP_PAUSE)
        else
            sleep(2.0)
            touch query("view marked:'#{option}'")
    end
    end

end

And(/^I should see the photo with no "(.*?)"$/) do |edit_item|
    if(edit_item == "frame") 
        selected_frame_status = query("UIImageView index:1",:accessibilityIdentifier)
    raise "Wrong frame selected!" unless selected_frame_status != nil
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
            
           selected_frame_status = query("UIImageView index:2",:accessibilityIdentifier).first
           raise "Wrong sticker selected!" unless selected_frame_status.to_s.strip == "v_xoxo"
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
    selected_frame_status = query("UIImageView index:1",:accessibilityIdentifier)
    raise "Blue line indicator not found!" unless selected_frame_status != nil
end

And(/^I verify blue line indicator is displayed under selected sticker$/) do 
    selected_sticker_status = query("UIImageView index:1",:accessibilityIdentifier)
    raise "Blue line indicator not found!" unless selected_sticker_status != nil
end

Given(/^I am on the "(.*?)" screen for "(.*?)"$/) do |screen_name, photo_source|
    if photo_source == "Instagram Preview"
        macro %Q|I am on the "Instagram Preview" screen|
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

 
Then(/^I select "(.*?)" frame$/) do |frame_name|
    sleep(WAIT_SCREENLOAD)
    select_frame frame_name
    sleep(STEP_PAUSE)
end

Then(/^I select "(.*?)" sticker$/) do |sticker_name|
    sleep(STEP_PAUSE)
    select_sticker sticker_name
    sleep(STEP_PAUSE)
end

Then(/^I should see the photo with the "(.*?)" frame$/) do |frame_name|
    $list_loc=$edit_screen_arr["edit_frame"]
    selected_frame_status = query("UIImageView index:1",:accessibilityIdentifier)
    raise "Wrong frame selected!" unless selected_frame_status = $list_loc[frame_name]
end

Then(/^I should see the photo with the "(.*?)" sticker$/) do |sticker_name|
    $list_loc=$edit_screen_arr["edit_sticker"]
    
    selected_sticker_status = query("IMGLYStickerImageView",:accessibilityIdentifier).first
    raise "Wrong sticker selected!" unless selected_sticker_status.to_s == $list_loc[sticker_name]
end

Then(/^I verify that all the "(.*?)" are applied successfully$/) do |option|
   sleep(STEP_PAUSE)
  frame_name=["Christmas Polka Dot Frame","Red Triangle Frame","Snow Frame","Striped Frame","Grey Frame","Santa Frame","White Frame", "Kraft Frame", "Floral Frame", "Orange Frame", "Polka Dots Frame", "Water Blue Frame", "Wood Bottom Frame", "Gradient Frame", "Sloppy Frame", "Turquoise Frame", "Red Frame","Green Water Color Frame","Floral 2 Frame","Pink Spray Paint Frame"]
    
    sticker_name=["v_xoxo_TN", "heart_2_TN", "v_hearts_TN", "conversation_heart_TN", "heart_wings_TN", "bird_TN", "butterfly_TN", "monster_2_TN", "rosebud_TN", "heart_bouquet_TN", "heart-garland_TN", "pig_TN", "headband_TN", "glasses_1_TN", "hat_TN", "bow2_TN", "balloons_TN", "thought_bubble_TN", "letter_TN", "holding_hands_TN", "love_monster_TN", "heart_arrow_TN", "smiley_TN", "heart_banner_TN", "lock_TN", "v_cupcake_TN", "v_cat_TN", "v_heart_TN", "target_TN", "glasses_TN", "tiara_TN", "heart_crown_TN", "sb_glasses_TN", "glasses_2_TN", "eye_black_TN", "foam_finger_TN", "heart_football3_TN", "banner_TN", "flag_TN", "heart_football_TN", "stars_n_balls_TN", "#_game_time_TN", "football_flames_TN", "love_TN", "i_heart_football_2_TN","owl_TN","goal_post_2_TN","helmet_TN","catglasses_TN","catwhiskers_TN","catears_TN","hearts_TN","xoxo_TN","heartExpress_TN","arrow_TN","crown_TN","birthdayHat_TN","moon_TN","starhp_TN","stars_TN","feather2_TN","feather_TN","leaf3_TN","cupcake_TN","cat_TN","diamond_TN","sunglasses_TN","OMG_TN"]   
    
 
  i = 0
    if option == "frames"
        while i < 16
            macro %Q|I select "#{frame_name[i]}" frame|
            macro %Q|I verify blue line indicator is displayed under selected frame|
            macro %Q|I should see the photo with the "#{frame_name[i]}" frame|
            macro %Q|I should see the "FrameEditor" screen|
            i= i + 1
            sleep(SLEEP_SCREENLOAD)
        end
    else
        while i < 68
            macro %Q|I select "#{sticker_name[i]}" sticker|
            macro %Q|I verify blue line indicator is displayed under selected sticker|
            macro %Q|I should see the photo with the "#{sticker_name[i]}" sticker|
            macro %Q|I should see the "StickerEditor" screen|
            macro %Q|I tap "Close" mark|
            macro %Q|I should see the "Edit" screen|
            macro %Q|I tap "Sticker" button|
            macro %Q|I should see the "StickerEditor" screen|
   
            i= i + 1
            sleep(SLEEP_SCREENLOAD)
        end 
    end
end

$edit_screen_arr =

{
    "edit_frame" => {
        "Christmas Polka Dot Frame" => "xmasPolka_Frame_iOS",
        "Red Triangle Frame" => "RedTriangle_Frame_iOS",
        "Snow Frame" => "Snow_Frame_iOS",
        "Striped Frame" => "striped_Frame_iOS",
        "Grey Frame" => "Grey_Frame_iOS",
        "Santa Frame" => "Santa_Frame_iOS",
        "White Frame" => "4_white_frame",
        "Kraft Frame" => "Kraft_Frame_iOS",
        "Floral Frame" => "6_floral_frame3",
        "Orange Frame"=> "Orange_Frame_iOS",
        "Polka Dots Frame" => "9_polkadots_frame",
        "Water Blue Frame" => "3_blue_watercolor_frame",
        "Wood Bottom Frame" => "Wood_Frame_iOS",
        "Gradient Frame"=> "7_gradient_frame",
        "Sloppy Frame" => "Sloppy_Frame_iOS",
        "Turquoise Frame" => "1_turquoise_frame",
        "Red Frame" => "5_Red_frame",
        "Green Water Color Frame"=> "10_green_watercolor_frame2",
        "Floral 2 Frame" => "13_floral2_frame",
        "Pink Spray Paint Frame" => "2_pink_spraypaint_frame2",
         },
        
    "edit_sticker" => {
            "v_xoxo_TN" => "v_xoxo",
            "heart_2_TN" => "heart_2",
            "v_hearts_TN" => "v_hearts",
            "conversation_heart_TN" => "conversation_heart",
            "heart_wings_TN" => "heart_wings",
            "bird_TN" => "bird",
            "butterfly_TN" => "butterfly",
            "monster_2_TN" => "monster_2",
            "rosebud_TN" => "rosebud",
            "heart_bouquet_TN" => "heart_bouquet",
            "heart-garland_TN" => "heart-garland",
            "pig_TN" => "pig",
            "headband_TN" => "headband",
            "glasses_1_TN" => "glasses_1",
            "hat_TN" => "hat",
            "bow2_TN" => "bow2",
            "balloons_TN" => "balloons",
            "thought_bubble_TN" => "thought_bubble",
            "letter_TN" => "letter",
            "holding_hands_TN" => "holding_hands",
            "love_monster_TN" => "love_monster",
            "heart_arrow_TN" => "heart_arrow",
            "smiley_TN" => "smiley",
            "heart_banner_TN" => "heart_banner",
            "lock_TN" => "lock",
            "v_cupcake_TN" => "v_cupcake",
            "v_cat_TN" => "v_cat",
            "v_heart_TN" => "v_heart",
            "target_TN" => "target",
            "glasses_TN" => "glasses",
            "tiara_TN" => "tiara",
            "heart_crown_TN" => "heart_crown",
            "sb_glasses_TN" => "sb_glasses",
            "glasses_2_TN" => "glasses_2",
            "eye_black_TN" => "eye_black",
            "foam_finger_TN" => "foam_finger",
            "heart_football3_TN" => "heart_football3",
            "banner_TN" => "banner",
            "flag_TN" => "flag",
            "heart_football_TN" => "heart_football",
            "stars_n_balls_TN" => "stars_n_balls",
            "#_game_time_TN" => "#_game_time",
            "football_flames_TN" => "football_flames",
            "love_TN" => "love",
            "i_heart_football_2_TN" => "i_heart_football_2",
            "owl_TN" => "owl",
            "goal_post_2_TN" => "goal_post_2",
            "helmet_TN" => "helmet",
            "catglasses_TN" => "catglasses",
            "catwhiskers_TN" => "catwhiskers",
            "catears_TN" => "catears",
            "hearts_TN" => "hearts",
            "xoxo_TN" => "xoxo",
            "heartExpress_TN" => "heartExpress",
            "arrow_TN" => "arrow",
            "crown_TN" => "crown",
            "birthdayHat_TN" => "birthdayHat",
            "moon_TN" => "moon",
            "starhp_TN" => "starhp",
            "stars_TN" => "stars",
            "feather2_TN" => "feather2",
            "feather_TN" => "feather",
            "leaf3_TN" => "leaf3",
            "cupcake_TN" => "cupcake",
            "cat_TN" => "cat",
            "stars_TN" => "stars",
            "diamond_TN" => "diamond",
            "sunglasses_TN" => "sunglasses",
            "OMG_TN" => "OMG"
        
            }
        
    }