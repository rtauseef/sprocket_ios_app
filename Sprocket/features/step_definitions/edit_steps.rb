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
      sleep(WAIT_SCREENLOAD)
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
        selected_frame_status = query("UIImageView",:accessibilityIdentifier)[9]
    raise "Wrong frame selected!" unless selected_frame_status == nil
    else
        if edit_item == "sticker"
           sticker_value=$sticker[$sticker_id]['value']
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
    selected_frame_status = query("UIImageView",:accessibilityIdentifier)[10]
    raise "Wrong frame selected!" unless selected_frame_status == frame_value
end

Then(/^I should see the photo with the "(.*?)" sticker$/) do |sticker_id|
    sticker_value=$sticker[sticker_id]['value']
    selected_sticker_status = query("IMGLYStickerImageView",:accessibilityLabel)[0]
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
                while i < 43
		sticker_id = "sticker_"+"#{i}"
                    macro %Q|I select "#{sticker_id}" sticker|
                    macro %Q|I am on the "StickerOptionEditor" screen|
                    macro %Q|I should see the photo with the "#{sticker_id}" sticker|
                    macro %Q|I touch "Delete"|
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
        "Gray" => 0.4898799061775208,
        "Black" => 0,
        "Light blue" => 0.1784424781799316,
        "Blue" => 0.3624181151390076,
        "Purple" => 0.554045557975769,
        "Orchid" => 0.9373828172683716,
        "Pink" => 1.081278085708618,
        "Red" => 1.081276059150696,
        "Orange" => 1.071406126022339,
        "Gold" => 1.038132071495056,
        "Yellow" => 1.00648832321167,
        "Olive" => 0.7447972893714905,
        "Green" => -0.3752276003360748,
        "Aquamarin" => -0.375214695930481
        
            },
    
    
    "edit_color_blue" => {
        
        "White" => 1,
        "Gray" => 0.4898685216903687,
        "Black" => 0,
        "Light blue" => 1.020771384239197,
        "Blue" => 1.032818078994751,
        "Purple" => 1.0355464220047,
        "Orchid" => 1.031528234481812,
        "Pink" => 0.8169015049934387,
        "Red" => 0.5235827565193176,
        "Orange" => 0.3609134554862976,
        "Gold" => 0.3108342885971069,
        "Yellow" => 0.2354578375816345,
        "Olive" => 0.2608795166015625,
        "Green" => 0.4687141180038452,
        "Aquamarin" => 0.920339047908783
        
            },
    
    
    "edit_color_green" => {
        
        "White" => 1,
        "Gray" => 0.489966094493866,
        "Black" => 0,
        "Light blue" => 0.8116050362586975,
        "Blue" => 0.534614086151123,
        "Purple" => 0.3933246433734894,
        "Orchid" => 0.3620219230651855,
        "Pink" => 0.3430601358413696,
        "Red" => 0.3430392444133759,
        "Orange" => 0.4967131018638611,
        "Gold" => 0.7901139855384827,
        "Yellow" => 0.968762218952179,
        "Olive" => 1.007340788841248,
        "Green" => 1.01670515537262,
        "Aquamarin" => 1.016713500022888
        
            }
    }
	
	$sticker ={ 
            'sticker_0' => {'name' => 'Hearts Doodle Sticker','value' =>'Hearts Doodle Sticker'},
            'sticker_1' => {'name' => 'Heart 2 Sticker','value' =>'Heart 2 Sticker'},
            'sticker_2' => {'name' => 'Palm Tree Sticker','value' =>'Palm Tree Sticker'},
            'sticker_3' => {'name' => 'Sunglasses Frogskin Sticker','value' =>'Sunglasses Frogskin Sticker'},
            'sticker_4' => {'name' => 'Cat Ears Sticker','value' =>'Cat Ears Sticker'},
            'sticker_5' => {'name' => 'Travel Car Sticker','value' =>'Travel Car Sticker'},
            'sticker_6' => {'name' => 'Sundae Sticker','value' =>'Sundae Sticker'},
            'sticker_7' => {'name' => 'Xoxo Sticker','value' =>'Xoxo Sticker'},
            'sticker_8' => {'name' => 'Hearts Sticker','value' =>'Hearts Sticker'},
            'sticker_9' => {'name' => 'Beach Ball Sticker','value' =>'Beach Ball Sticker'},
            'sticker_10' => {'name' => 'Aviator Glasses Sticker','value' =>'Aviator Glasses Sticker'},
            'sticker_11' => {'name' => 'Scuba Mask Sticker','value' =>'Scuba Mask Sticker'},
            'sticker_12' => {'name' => 'Travel Car Woody Sticker','value' =>'Travel Car Woody Sticker'},
            'sticker_13' => {'name' => 'Ice Cream Tub Sticker','value' =>'Ice Cream Tub Sticker'},
            'sticker_14' => {'name' => 'Heart Express Sticker','value' =>'Heart Express Sticker'},
            'sticker_15' => {'name' => 'Heart Garland Sticker','value' =>'Heart Garland Sticker'},
            'sticker_16' => {'name' => 'Wave Sticker','value' =>'Wave Sticker'},
            'sticker_17' => {'name' => 'Glasses Sticker','value' =>'Glasses Sticker'},
            'sticker_18' => {'name' => 'Swim Fins Sticker','value' =>'Swim Fins Sticker'},
            'sticker_19' => {'name' => 'Bike Cruiser Sticker','value' =>'Bike Cruiser Sticker'},
            'sticker_20' => {'name' => 'Cupcake Sticker','value' =>'Cupcake Sticker'},
            'sticker_21' => {'name' => 'Heart Sticker','value' =>'Heart Sticker'},
            'sticker_22' => {'name' => 'Valentines Xoxo Sticker','value' =>'Valentines Xoxo Sticker'},
            'sticker_23' => {'name' => 'Beach Umbrella Sticker','value' =>'Beach Umbrella Sticker'},
            'sticker_24' => {'name' => 'Bunny Ears Flowers Sticker','value' =>'Bunny Ears Flowers Sticker'},
            'sticker_25' => {'name' => 'Volley Ball Sticker','value' =>'Volley Ball Sticker'},
            'sticker_26' => {'name' => 'Airplane Sticker','value' =>'Airplane Sticker'},
            'sticker_27' => {'name' => 'BBQ Sticker','value' =>'BBQ Sticker'},
            'sticker_28' => {'name' => 'Glasses 1 Sticker','value' =>'Glasses 1 Sticker'},
            'sticker_29' => {'name' => 'Heart Wings Sticker','value' =>'Heart Wings Sticker'},
            'sticker_30' => {'name' => 'Sun Face Sticker','value' =>'Sun Face Sticker'},
            'sticker_31' => {'name' => 'Cat Glasses Sticker','value' =>'Cat Glasses Sticker'},
            'sticker_32' => {'name' => 'Trailer Sticker','value' =>'Trailer Sticker'},
            'sticker_33' => {'name' => 'Soda Straw Sticker','value' =>'Soda Straw Sticker'},
            'sticker_34' => {'name' => 'Unicorn Float Sticker','value' =>'Unicorn Float Sticker'},
            'sticker_35' => {'name' => 'Surf Board Sticker', 'value'=>'Surf Board Sticker'},
            'sticker_36' => {'name' => 'Crown Sticker', 'value'=>'Crown Sticker'},
            'sticker_37' => {'name' => 'Stars Sticker', 'value'=>'Stars Sticker'},
            'sticker_38' => {'name' => 'Smiley Sticker', 'value'=>'Smiley Sticker'},
            'sticker_39' => {'name' => 'Birthday Hat Sticker', 'value'=>'Birthday Hat Sticker'},
            'sticker_40' => {'name' => 'Star Sticker', 'value'=>'Star Sticker'},
            'sticker_41' => {'name' => 'Cat Face Sticker', 'value'=>'Cat Face Sticker'},
            'sticker_42' => {'name' => 'Feather Sticker', 'value'=>'Feather Sticker'},
            'sticker_43' => {'name' => 'Diamond Sticker', 'value'=>'Diamond Sticker'},

          }
           $frame ={ 
            'frame_0' => {'name' => 'HeartsOverlayFrame_TN','value' =>'HeartsOverlayFrame'},
            'frame_1' => {'name' => 'SloppyFrame_TN','value' =>'SloppyFrame'},
            'frame_2' => {'name' => 'RainbowFrame_TN','value' =>'RainbowFrame'},
            'frame_3' => {'name' => 'WhiteFrame_TN','value' =>'WhiteFrame'},
            'frame_4' => {'name' => 'StarsOverlayFrame_TN','value' =>'StarsOverlayFrame'},
            'frame_5' => {'name' => 'PolkadotsFrame_TN','value' =>'PolkadotsFrame'},
            'frame_6' => {'name' => 'GreyShadowFrame_TN','value' =>'GreyShadowFrame'},
            'frame_7' => {'name' => 'PinkTriangleFrame_TN','value' =>'PinkTriangleFrame'},
            'frame_8' => {'name' => 'WhiteRoundedFrame_TN','value' =>'WhiteRoundedFrame'},
            'frame_9' => {'name' => 'Floral2Frame_TN','value' =>'Floral2Frame'},
            'frame_10' => {'name' => 'BlueWatercoloFrame_TN','value' =>'BlueWatercoloFrame'},
            'frame_11' => {'name' => 'FloralOverlayFrame_TN','value' =>'FloralOverlayFrame'},
            'frame_12' => {'name' => 'RedFrame_TN','value' =>'RedFrame'},
            'frame_13' => {'name' => 'GradientFrame_TN','value' =>'GradientFrame'},
            'frame_14' => {'name' => 'TurquoiseFrame_TN','value' =>'TurquoiseFrame'},
            'frame_15' => {'name' => 'DotsOverlayFrame_TN','value' =>'DotsOverlayFrame'},
            'frame_16' => {'name' => 'KraftFrame_TN','value' =>'KraftFrame'},
            'frame_17' => {'name' => 'WhiteBarFrame_TN','value' =>'WhiteBarFrame'},
            'frame_18' => {'name' => 'PinkSpraypaintFrame_TN','value' =>'PinkSpraypaintFrame'},
            'frame_19' => {'name' => 'WhiteFullFrame_TN','value' =>'WhiteFullFrame'}
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
           
    