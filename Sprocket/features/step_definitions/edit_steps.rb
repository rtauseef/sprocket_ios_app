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
            if option == "2:3" || option == "3:2"
                $crop_option = option
                sleep(2.0)
                touch query("view marked:'#{option}'")
            else
                sleep(2.0)
                touch query("view marked:'#{option}'")
            end
        end
end

And(/^I should see the photo with no "(.*?)"$/) do |edit_item|
    if(edit_item == "frame") 
        frame_value=$frame[$frame_id]['value']
       
        selected_frame_status = query("UIImageView index:1",:accessibilityIdentifier)
    raise "Wrong frame selected!" unless selected_frame_status != nil
    else
        if edit_item == "sticker"
           sticker_value=$sticker[$sticker_id]['value']
           selected_sticker_status = query("UIImageView",:accessibilityIdentifier)[7]
           raise "Sticker present!" unless selected_sticker_status.to_s != sticker_value
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



And(/^I verify blue line indicator is displayed under selected "(.*?)"$/) do |option|
    selected_status = query("UIImageView index:1",:accessibilityIdentifier)
    raise "Blue line indicator not found!" unless selected_status != nil
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
    post_photo_frame_height = query("GLKView").first["frame"]["height"]
    post_photo_frame_width = query("GLKView").first["frame"]["width"]
    if option == "cropped"
        if $crop_option == "3:2"
            raise "Image is not cropped!" unless post_photo_frame_height < $curr_edit_img_frame_height
        else
            if $crop_option == "2:3"
                raise "Image is not cropped!" unless post_photo_frame_width < $curr_edit_img_frame_width
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
    frame_name=$frame[frame_id]['name']
    select_frame frame_name
    sleep(STEP_PAUSE)
end

Then(/^I select "(.*?)" sticker$/) do |sticker_id|
    sleep(STEP_PAUSE)
    $sticker_id = sticker_id
    sticker_name=$sticker[sticker_id]['name']
    select_sticker sticker_name
    sleep(STEP_PAUSE)
end

Then(/^I select "(.*?)" font$/) do |font_id|
    sleep(STEP_PAUSE)
    $font_id = font_id
    font_name=$font[font_id]['name']
    select_font font_name
    sleep(STEP_PAUSE)
end

Then(/^I select "(.*?)" color$/) do |color_name|
    sleep(STEP_PAUSE)
    select_color color_name
    sleep(STEP_PAUSE)
end

Then(/^I should see the photo with the "(.*?)" frame$/) do |frame_id|
    frame_value=$frame[frame_id]['value']
    
    selected_frame_status = query("UIImageView",:accessibilityIdentifier)[6]
    
    raise "Wrong frame selected!" unless selected_frame_status == frame_value
end

Then(/^I should see the photo with the "(.*?)" sticker$/) do |sticker_id|
    sticker_value=$sticker[sticker_id]['value']
    selected_sticker_status = query("UIImageView",:accessibilityIdentifier)[7]
    raise "Wrong sticker selected!" unless selected_sticker_status.to_s == sticker_value
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
  #frame_name=["Valentines Hearts Frame","Valentines Pink Polka Frame","Valentines Red Frame","Valentines Hearts Overlay Frame","Valentines Pink Watercolor Frame","Valentines Red Stripes Frame","White Frame", "Kraft Frame", "Floral Frame", "Orange Frame", "Polka Dots Frame", "Water Blue Frame", "Wood Bottom Frame", "Gradient Frame", "Sloppy Frame", "Turquoise Frame", "Red Frame","Green Water Color Frame","Floral 2 Frame","Pink Spray Paint Frame"]
    
   # sticker_name=["v_xoxo_TN", "heart_2_TN", "v_hearts_TN", "conversation_heart_TN", "heart_wings_TN", "bird_TN", "butterfly_TN", "monster_2_TN", "rosebud_TN", "heart_bouquet_TN", "heart-garland_TN", "pig_TN", "headband_TN", "glasses_1_TN", "hat_TN", "bow2_TN", "balloons_TN", "thought_bubble_TN", "letter_TN", "holding_hands_TN", "love_monster_TN", "heart_arrow_TN", "smiley_TN", "heart_banner_TN", "lock_TN", "v_cupcake_TN", "v_cat_TN", "v_heart_TN", "target_TN", "glasses_TN", "tiara_TN", "heart_crown_TN", "sb_glasses_TN", "glasses_2_TN", "eye_black_TN", "foam_finger_TN", "heart_football3_TN", "banner_TN", "flag_TN", "heart_football_TN", "stars_n_balls_TN", "#_game_time_TN", "football_flames_TN", "love_TN", "i_heart_football_2_TN","owl_TN","goal_post_2_TN","helmet_TN","catglasses_TN","catwhiskers_TN","catears_TN","hearts_TN","xoxo_TN","heartExpress_TN","arrow_TN","crown_TN","birthdayHat_TN","moon_TN","starhp_TN","stars_TN","feather2_TN","feather_TN","leaf3_TN","cupcake_TN","cat_TN","diamond_TN","sunglasses_TN","OMG_TN"]   
    
   # font_name=["Helvetica", "Typewriter", "Avenir", "Chalkboard", "Arial", "Kohinoor", "Liberator", "Muncie", "Lincoln", "Airship", "Arvil", "Bender", "Blanch", "Cubano", "Franchise", "Geared", "Governor", "Haymaker", "Homestead", "Maven Pro", "Mensch", "Sullivan", "Tommaso", "Valencia", "Vevey"]
    
    color_name=["White", "Gray", "Black", "Light blue", "Blue", "Purple", "Orchid", "Pink", "Red", "Orange", "Gold", "Yellow", "Olive", "Green", "Aquamarin"]
    
 
  i = 0
    if option == "frames"
        while i < 20
            frame_id = "frame_"+"#{i}"
            macro %Q|I select "#{frame_id}" frame|
            macro %Q|I verify blue line indicator is displayed under selected "frame"|
            macro %Q|I should see the photo with the "#{frame_id}" frame|
            macro %Q|I should see the "FrameEditor" screen|
            i= i + 1
            sleep(SLEEP_SCREENLOAD)
        end
    else
        if option == "fonts"
            while i < 25
                 font_id = "font_"+"#{i}"
                macro %Q|I select "#{font_id}" font|
                macro %Q|I verify blue line indicator is displayed under selected "font"|
                macro %Q|I should see the photo with the "#{font_id}" font|
                i= i + 1
            end
        else
            if option == "colors" || option == "Background colors"
                while i < 15
                    $option = option
                    macro %Q|I select "#{color_name[i]}" color|
                    macro %Q|I verify blue line indicator is displayed under selected "color"|
                    macro %Q|I should see the photo with the "#{color_name[i]}" color|
                    i= i + 1
                end
            else
                while i < 63
		sticker_id = "sticker_"+"#{i}"
                    macro %Q|I select "#{sticker_id}" sticker|
                    macro %Q|I verify blue line indicator is displayed under selected "sticker"|
                    macro %Q|I should see the photo with the "#{sticker_id}" sticker|
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
    end
end

$edit_screen_arr =

{
   
    
    "edit_color_red" => {
        
        "White" => 1,
        "Gray" => 0.49,
        "Black" => 0,
        "Light blue" => 0.4,
        "Blue" => 0.4,
        "Purple" => 0.53,
        "Orchid" => 0.87,
        "Pink" => 1,
        "Red" => 1,
        "Orange" => 1,
        "Gold" => 1,
        "Yellow" => 1,
        "Olive" => 0.8,
        "Green" => 0.33,
        "Aquamarin" => 0.33
        
            },
    
    
    "edit_color_blue" => {
        
        "White" => 1,
        "Gray" => 0.49,
        "Black" => 0,
        "Light blue" => 1,
        "Blue" => 1,
        "Purple" => 1,
        "Orchid" => 1,
        "Pink" => 0.8,
        "Red" => 0.53,
        "Orange" => 0.4,
        "Gold" => 0.4,
        "Yellow" => 0.39,
        "Olive" => 0.4,
        "Green" => 0.53,
        "Aquamarin" => 0.92
        
            },
    
    
    "edit_color_green" => {
        
        "White" => 1,
        "Gray" => 0.49,
        "Black" => 0,
        "Light blue" => 0.8,
        "Blue" => 0.53,
        "Purple" => 0.4,
        "Orchid" => 0.4,
        "Pink" => 0.4,
        "Red" => 0.4,
        "Orange" => 0.53,
        "Gold" => 0.8,
        "Yellow" => 0.97,
        "Olive" => 1,
        "Green" => 1,
        "Aquamarin" => 1
        
            }
    }
	
	$sticker ={ 
            'sticker_0' => {'name' => 'glasses_2b_TN','value' =>'glasses_2b'},
            'sticker_1' => {'name' => 'hat_1b_TN','value' =>'hat_1b'},
            'sticker_2' => {'name' => 'kiss_me_2c_TN','value' =>'kiss_me_2c'},
            'sticker_3' => {'name' => 'derby_TN','value' =>'derby'},
            'sticker_4' => {'name' => 'st_hearts_TN','value' =>'st_hearts'},
            'sticker_5' => {'name' => 'st_glasses_TN','value' =>'st_glasses'},
            'sticker_6' => {'name' => 'boppers_TN','value' =>'boppers'},
            'sticker_7' => {'name' => 'lips_TN','value' =>'lips'},
            'sticker_8' => {'name' => 'bow_tie_TN','value' =>'bow_tie'},
            'sticker_9' => {'name' => 'beard&-eyebrows_TN','value' =>'beard&-eyebrows'},
            'sticker_10' => {'name' => 'mustache_TN','value' =>'mustache'},
            'sticker_11' => {'name' => 'pot_o_gold_TN','value' =>'pot_o_gold'},
            'sticker_12' => {'name' => 'rainbow_2_TN','value' =>'rainbow_2'},
            'sticker_13' => {'name' => 'shamrock_crown_TN','value' =>'shamrock_crown'},
            'sticker_14' => {'name' => 'shamrock_2_TN','value' =>'shamrock_2'},
            'sticker_15' => {'name' => '#lucky_new_TN','value' =>'#lucky_new'},
            'sticker_16' => {'name' => 'shamrockin_3_TN','value' =>'shamrockin_3'},
            'sticker_17' => {'name' => 'clover_headband_TN','value' =>'clover_headband'},
            'sticker_18' => {'name' => 'clover_wand_TN','value' =>'clover_wand'},
            'sticker_19' => {'name' => 'hearts_TN','value' =>'hearts'},
            'sticker_20' => {'name' => 'xoxo_TN','value' =>'xoxo'},
            'sticker_21' => {'name' => 'heartExpress_TN','value' =>'heartExpress'},
            'sticker_22' => {'name' => 'v_heart_TN','value' =>'v_heart'},
            'sticker_23' => {'name' => 'glasses_1_TN','value' =>'glasses_1'},
            'sticker_24' => {'name' => 'heart_2_TN','value' =>'heart_2'},
            'sticker_25' => {'name' => 'v_hearts_TN','value' =>'v_hearts'},
            'sticker_26' => {'name' => 'heart-garland_TN','value' =>'heart-garland'},
            'sticker_27' => {'name' => 'v_xoxo_TN','value' =>'v_xoxo'},
            'sticker_28' => {'name' => 'heart_wings_TN','value' =>'heart_wings'},
            'sticker_29' => {'name' => 'palmtree_TN','value' =>'palmtree'},
            'sticker_30' => {'name' => 'beachball_TN','value' =>'beachball'},
            'sticker_31' => {'name' => 'wave_TN','value' =>'wave'},
            'sticker_32' => {'name' => 'beach_umbrella_TN','value' =>'beach_umbrella'},
            'sticker_33' => {'name' => 'sun_face_TN','value' =>'sun_face'},
            'sticker_34' => {'name' => 'sunglasses_frogskin_TN','value' =>'sunglasses_frogskin'},
            'sticker_35' => {'name' => 'aviator_glasses_TN','value' =>'aviator_glasses'},
            'sticker_36' => {'name' => 'glasses_TN','value' =>'glasses'},
            'sticker_37' => {'name' => 'bunny_ears_flowers_TN','value' =>'bunny_ears_flowers'},
            'sticker_38' => {'name' => 'catglasses_TN','value' =>'catglasses'},
            'sticker_39' => {'name' => 'catears_TN','value' =>'catears'},
            'sticker_40' => {'name' => 'scuba_mask_TN','value' =>'scuba_mask'},
            'sticker_41' => {'name' => 'swim_fins_TN','value' =>'swim_fins'},
            'sticker_42' => {'name' => 'volleyball_TN','value' =>'volleyball'},
            'sticker_43' => {'name' => 'trailer_TN','value' =>'trailer'},
            'sticker_44' => {'name' => 'travel_car_bug_TN','value' =>'travel_car_bug'},
            'sticker_45' => {'name' => 'travel_car_woody_TN','value' =>'travel_car_woody'},
            'sticker_46' => {'name' => 'bike_cruiser_TN','value' =>'bike_cruiser'},
            'sticker_47' => {'name' => 'airplane_TN','value' =>'airplane'},
            'sticker_48' => {'name' => 'soda_straw_TN','value' =>'soda_straw'},
            'sticker_49' => {'name' => 'sundae_TN','value' =>'sundae'},
            'sticker_50' => {'name' => 'icecream_tub_TN','value' =>'icecream_tub'},
            'sticker_51' => {'name' => 'cupcake_TN','value' =>'cupcake'},
            'sticker_52' => {'name' => 'bbq_TN','value' =>'bbq'},
            'sticker_53' => {'name' => 'unicorn_float_TN','value' =>'unicorn_float'},
            'sticker_54' => {'name' => 'surfboard_TN','value' =>'surfboard'},
            'sticker_55' => {'name' => 'crown_TN','value' =>'crown'},
            'sticker_56' => {'name' => 'birthdayHat_TN','value' =>'birthdayHat'},
            'sticker_57' => {'name' => 'diamond_TN','value' =>'diamond'},
            'sticker_58' => {'name' => 'feather_TN','value' =>'feather'},
            'sticker_59' => {'name' => 'stars_TN','value' =>'stars'},
            'sticker_60' => {'name' => 'starhp_TN','value' =>'starhp'},
            'sticker_61' => {'name' => 'cat_TN','value' =>'cat'},
            'sticker_62' => {'name' => 'smiley_TN','value' =>'smiley'}
          }
           $frame ={ 
            'frame_0' => {'name' => 'Valentines Hearts Frame','value' =>'Hearts_Frame_iOS'},
            'frame_1' => {'name' => 'Valentines Pink Polka Frame','value' =>'PinkPolka_Frame_iOS'},
            'frame_2' => {'name' => 'Valentines Red Frame','value' =>'Red_Frame_iOS'},
            'frame_3' => {'name' => 'Valentines Hearts Overlay Frame','value' =>'HeartsOverlay_Frame_iOS'},
            'frame_4' => {'name' => 'Valentines Pink Watercolor Frame','value' =>'PinkWatercolor_Frame_iOS'},
            'frame_5' => {'name' => 'Valentines Red Stripes Frame','value' =>'RedStripes_Frame_iOS'},
            'frame_6' => {'name' => 'White Frame','value' =>'4_white_frame'},
            'frame_7' => {'name' => 'Kraft Frame','value' =>'Kraft_Frame_iOS'},
            'frame_8' => {'name' => 'Floral Frame','value' =>'6_floral_frame3'},
            'frame_9' => {'name' => 'Orange Frame','value' =>'Orange_Frame_iOS'},
            'frame_10' => {'name' => 'Polka Dots Frame','value' =>'9_polkadots_frame'},
            'frame_11' => {'name' => 'Water Blue Frame','value' =>'3_blue_watercolor_frame'},
            'frame_12' => {'name' => 'Wood Bottom Frame','value' =>'Wood_Frame_iOS'},
            'frame_13' => {'name' => 'Gradient Frame','value' =>'7_gradient_frame'},
            'frame_14' => {'name' => 'Sloppy Frame','value' =>'Sloppy_Frame_iOS'},
            'frame_15' => {'name' => 'Turquoise Frame','value' =>'1_turquoise_frame'},
            'frame_16' => {'name' => 'Red Frame','value' =>'5_Red_frame'},
            'frame_17' => {'name' => 'Green Water Color Frame','value' =>'10_green_watercolor_frame2'},
            'frame_18' => {'name' => 'Floral 2 Frame','value' =>'13_floral2_frame'},
            'frame_19' => {'name' => 'Pink Spray Paint Frame','value' =>'5_Red_frame'}
        }
        $font ={ 
            'font_0' => {'name' => 'Helvetica','value' =>'Helvetica'},
            'font_1' => {'name' => 'Typewriter','value' =>'American'},
            'font_2' => {'name' => 'Avenir','value' =>'Avenir-Heavy'},
            'font_3' => {'name' => 'Chalkboard','value' =>'ChalkboardSE-Regular'},
            'font_4' => {'name' => 'Arial','value' =>'Arial'},
            'font_5' => {'name' => 'Kohinoor','value' =>'KohinoorBangla-Regular'},
            'font_6' => {'name' => 'Liberator','value' =>'Liberator'},
            'font_7' => {'name' => 'Muncie','value' =>'Muncie'},
            'font_8' => {'name' => 'Lincoln','value' =>'Abraham'},
            'font_9' => {'name' => 'Airship','value' =>'Airship'},
            'font_10' => {'name' => 'Arvil','value' =>'Arvil'},
            'font_11' => {'name' => 'Bender','value' =>'Bender-Inline'},
            'font_12' => {'name' => 'Blanch','value' =>'Blanch-Condensed'},
            'font_13' => {'name' => 'Cubano','value' =>'Cubano-Regular'},
            'font_14' => {'name' => 'Franchise','value' =>'Franchise'},
            'font_15' => {'name' => 'Geared','value' =>'GearedSlab-Regular'},
            'font_16' => {'name' => 'Governor','value' =>'Governor'},
            'font_17' => {'name' => 'Haymaker','value' =>'Haymaker'},
            'font_18' => {'name' => 'Homestead','value' =>'Homestead-Regular'},
            'font_19' => {'name' => 'Maven Pro','value' =>'MavenProLight200-Regular'},
            'font_20' => {'name' => 'Mensch','value' =>'Mensch'},
            'font_21' => {'name' => 'Sullivan','value' =>'Sullivan-Regular'},
            'font_22' => {'name' => 'Tommaso','value' =>'Tommaso'},
            'font_23' => {'name' => 'Valencia','value' =>'Valencia'},
            'font_24' => {'name' => 'Vevey','value' =>'Vevey'}                  
        }
           
    