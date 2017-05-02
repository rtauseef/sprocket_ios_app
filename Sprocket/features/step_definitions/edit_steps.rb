require 'securerandom'

Then (/^I should see "(.*?)" mark$/) do |mark|
    if(mark == "Close")
        check_element_exists(@current_page.close)
    else 
        if mark = "Undo"
            check_element_exists(@current_page.undo)
        else
            if mark = "Redo"
                check_element_exists(@current_page.redo)
            else
                check_element_exists(@current_page.check)
            end
        end
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



=begin
And(/^I verify blue line indicator is displayed under selected "(.*?)"$/) do |option|
    selected_status = query("UIImageView index:1",:accessibilityIdentifier)
    raise "Blue line indicator not found!" unless selected_status != nil
end
=end

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
    sticker_name=$sticker[$sticker_tab][sticker_id]['name']
    #sticker_name=$sticker[$sticker_tab_0][sticker_id]['name']
    select_sticker sticker_name
    sleep(STEP_PAUSE)
end
Then(/^I select "([^"]*)" tab$/) do |sticker_tab|
  sleep(STEP_PAUSE)
  $sticker_tab = sticker_tab
  split_sticker_tab = sticker_tab.split("_")
  split_sticker_tab_id = split_sticker_tab[2].to_i
  touch query("IMGLYIconBorderedCollectionViewCell")[split_sticker_tab_id]
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
    #selected_frame_status = query("UIImageView",:accessibilityIdentifier)[10]
    selected_frame_status = query("UIImageView",:accessibilityIdentifier)[8]
    raise "Wrong frame selected!" unless selected_frame_status == frame_value
end

Then(/^I should see the photo in the "Frame Editor" screen with the "(.*?)" frame$/) do |frame_id|
    frame_value=$frame[frame_id]['value']
    selected_frame_status = query("UIImageView",:accessibilityIdentifier)[10]
    raise "Wrong frame selected!" unless selected_frame_status == frame_value
end

Then(/^I should see the photo with the "(.*?)" sticker$/) do |sticker_id|
    sticker_value=$sticker[$sticker_tab][sticker_id]['value']
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
        while i < 19
            frame_id = "frame_"+"#{i}"
            macro %Q|I select "#{frame_id}" frame|
            macro %Q|I tap "Save" mark|
            macro %Q|I should see the "Edit" screen|
            macro %Q|I should see the photo with the "#{frame_id}" frame|
            macro %Q|I tap "Frame" button|
            macro %Q|I should see the "FrameEditor" screen|
            i= i + 1
            sleep(SLEEP_SCREENLOAD)
        end
    else
        if option == "fonts"
            while i < 20
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
                stic_count=$sticker[$sticker_tab].length
               
                while i < stic_count
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

Then(/^I should see the all the corresponding "([^"]*)"$/) do |item|
    check_sticker_exists item
 end
Then(/^I should see the "([^"]*)" with "([^"]*)" Color$/) do |type, color|
  description = query("IMGLYStickerImageView", :description)[0]
  selected_flag = query("view marked:'#{color}'", :isSelected).first
  raise "#{color} no selected!" unless  (description.include? "tintColor") && (selected_flag = 1)
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
        'sticker_tab_0' => {
            'sticker_0' => {'name' => 'Flowers Left Sticker','value' =>'Flowers Left Sticker'},
            'sticker_1' => {'name' => 'Flowers Daisies Sticker','value' =>'Flowers Daisies Sticker'},
            'sticker_2' => {'name' => 'Rose Sticker','value' =>'Rose Sticker'},
            'sticker_3' => {'name' => 'Girl Flower Sticker','value' =>'Girl Flower Sticker'},
            'sticker_4' => {'name' => 'Rosebud Leaves Sticker','value' =>'Rosebud Leaves Sticker'},
            'sticker_5' => {'name' => 'Aster Flower Sticker','value' =>'Aster Flower Sticker'},
            #'sticker_6' => {'name' => 'Mother's Day Sticker','value' =>'Mother's Day Sticker'},
            'sticker_6' => {'name' => 'Flower Sticker','value' =>'Flower Sticker'},
            'sticker_7' => {'name' => 'Snails Sticker','value' =>'Snails Sticker'},
            'sticker_8' => {'name' => 'Envelope Sticker','value' =>'Envelope Sticker'},
            'sticker_9' => {'name' => 'Three Flowers Bunch Sticker','value' =>'Three Flowers Bunch Sticker'},
            'sticker_10' => {'name' => 'Envelope Flowers Sticker','value' =>'Envelope Flowers Sticker'},
            'sticker_11' => {'name' => 'Banner Flowers Sticker','value' =>'Banner Flowers Sticker'},
            'sticker_12' => {'name' => 'Heart Mom Sticker','value' =>'Heart Mom Sticker'},
            'sticker_13' => {'name' => 'Mother Giraffe Sticker','value' =>'Mother Giraffe Sticker'},
            'sticker_14' => {'name' => 'Silhoutte Sticker','value' =>'Silhoutte Sticker'},
            'sticker_15' => {'name' => 'Three Daisies Sticker','value' =>'Three Daisies Sticker'},
            'sticker_16' => {'name' => 'Cat Holding Flowers Sticker','value' =>'Cat Holding Flowers Sticker'},
            'sticker_17' => {'name' => 'Banner Flowers 2 Sticker','value' =>'Banner Flowers 2 Sticker'},
            'sticker_18' => {'name' => 'Pacifier Sticker','value' =>'Pacifier Sticker'},
            'sticker_19' => {'name' => 'Mother Turtle Sticker','value' =>'Mother Turtle Sticker'},
            'sticker_20' => {'name' => 'Mom Tattoo Sticker','value' =>'Mom Tattoo Sticker'},
            'sticker_21' => {'name' => 'We Love You Sticker','value' =>'We Love You Sticker'},
            'sticker_22' => {'name' => 'Flowers Right Sticker','value' =>'Flowers Right Sticker'},
            'sticker_23' => {'name' => 'Bouquet Sticker','value' =>'Bouquet Sticker'},
            'sticker_24' => {'name' => 'Feather Color Sticker','value' =>'Feather Color Sticker'},
            'sticker_25' => {'name' => 'Three Rosebuds Sticker','value' =>'Three Rosebuds Sticker'},
            'sticker_26' => {'name' => 'Mom Child Cats Sticker','value' =>'Mom Child Cats Sticker'}
        },

        'sticker_tab_1' => {
            'sticker_0' => {'name' => 'Graduation Glasses Sticker','value' =>'Graduation Glasses Sticker'},
            'sticker_1' => {'name' => 'Graduation Horn Sticker','value' =>'Graduation Horn Sticker'},
            'sticker_2' => {'name' => 'Owl Sticker','value' =>'Owl Sticker'},
            'sticker_3' => {'name' => 'Necktie Graduation Sticker','value' =>'Necktie Graduation Sticker'},
            'sticker_4' => {'name' => 'Ribbon Graduation Sticker','value' =>'Ribbon Graduation Sticker'},
            'sticker_5' => {'name' => 'Cap Sticker','value' =>'Cap Sticker'},
            'sticker_6' => {'name' => 'Medal Sticker','value' =>'Medal Sticker'},
            'sticker_7' => {'name' => 'Nerd Glasses Sticker','value' =>'Nerd Glasses Sticker'},
            'sticker_8' => {'name' => 'Bowtie Graduation Sticker','value' =>'Bowtie Graduation Sticker'},
            'sticker_9' => {'name' => 'Flying Caps Graduation Sticker','value' =>'Flying Caps Graduation Sticker'},
            'sticker_10' => {'name' => 'Diploma Sticker','value' =>'Diploma Sticker'},
            'sticker_11' => {'name' => 'Ribbon Sticker','value' =>'Ribbon Sticker'},
            'sticker_12' => {'name' => 'Cap Graduation Sticker','value' =>'Cap Graduation Sticker'},
            'sticker_13' => {'name' => 'Medal Gratuation Sticker','value' =>'Medal Gratuation Sticker'},
            'sticker_14' => {'name' => 'Graduation Balloons Sticker','value' =>'Graduation Balloons Sticker'},
            'sticker_15' => {'name' => 'Books Sticker','value' =>'Books Sticker'},
            'sticker_16' => {'name' => 'Diploma Doodle Sticker','value' =>'Diploma Doodle Sticker'},
            'sticker_17' => {'name' => 'Book Stack Sticker','value' =>'Book Stack Sticker'},
            'sticker_18' => {'name' => 'Confetti Sticker','value' =>'Confetti Sticker'},
            'sticker_19' => {'name' => 'Pencil Sticker','value' =>'Pencil Sticker'},
            'sticker_20' => {'name' => 'Confetti Graduation Sticker','value' =>'Confetti Graduation Sticker'},
            'sticker_21' => {'name' => 'Pencil Graduation Sticker','value' =>'Pencil Graduation Sticker'}
        },
        'sticker_tab_2' => {
            'sticker_0' => {'name' => 'Aviator Glasses Color Sticker','value' =>'Aviator Glasses Color Sticker'},
            'sticker_1' => {'name' => 'Bunny Ears Flowers Sticker','value' =>'Bunny Ears Flowers Sticker'},
            'sticker_2' => {'name' => 'Rabbit Mask Sticker','value' =>'Rabbit Mask Sticker'},
            'sticker_3' => {'name' => 'Sun Hat Sticker','value' =>'Sun Hat Sticker'},
            'sticker_4' => {'name' => 'Panda Mask Sticker','value' =>'Panda Mask Sticker'},
            'sticker_5' => {'name' => 'Beard Sticker','value' =>'Beard Sticker'},
            'sticker_6' => {'name' => 'Lips Sticker','value' =>'Lips Sticker'},
            'sticker_7' => {'name' => 'Cat Ears Sticker','value' =>'Cat Ears Sticker'},
            'sticker_8' => {'name' => 'Cat Whiskers Sticker','value' =>'Cat Whiskers Sticker'},
            'sticker_9' => {'name' => 'Derby Sticker','value' =>'Derby Sticker'},
            'sticker_10' => {'name' => 'Devil Horns Sticker','value' =>'Devil Horns Sticker'},
            'sticker_11' => {'name' => 'Glasses Football Sticker','value' =>'Glasses Football Sticker'},
            'sticker_12' => {'name' => 'Cat Glasses Sticker','value' =>'Cat Glasses Sticker'},
            'sticker_13' => {'name' => 'Crown Sticker','value' =>'Crown Sticker'},
            'sticker_14' => {'name' => 'Birthday Hat Sticker','value' =>'Birthday Hat Sticker'},
            'sticker_15' => {'name' => 'Glasses Red Sticker','value' =>'Glasses Red Sticker'},
            'sticker_16' => {'name' => 'Sunglasses Sticker','value' =>'Sunglasses Sticker'},
            'sticker_17' => {'name' => 'Glasses 1 Sticker','value' =>'Glasses 1 Sticker'},
            'sticker_18' => {'name' => 'Party Hat Sticker','value' =>'Party Hat Sticker'},
            'sticker_19' => {'name' => 'Glasses Blinds Sticker','value' =>'Glasses Blinds Sticker'},
            'sticker_20' => {'name' => 'Mustache Brown Sticker','value' =>'Mustache Brown Sticker'},
            'sticker_21' => {'name' => 'Glasses Sticker','value' =>'Glasses Sticker'},
            'sticker_22' => {'name' => 'Aviator Glasses Sticker','value' =>'Aviator Glasses Sticker'},
            'sticker_23' => {'name' => 'Glasses Blossom Sticker','value' =>'Glasses Blossom Sticker'},
            'sticker_24' => {'name' => 'Cat on Head Sticker','value' =>'Cat on Head Sticker'},
            'sticker_25' => {'name' => 'Mustache Dark Sticker','value' =>'Mustache Dark Sticker'}
        },
        'sticker_tab_3' => {
            'sticker_0' => {'name' => 'Heart Garland Sticker','value' =>'Heart Garland Sticker'},
            'sticker_1' => {'name' => 'Stars Bunch Sticker','value' =>'Stars Bunch Sticker'},
            'sticker_2' => {'name' => '3D diamond 2 Sticker','value' =>'3D diamond 2 Sticker'},
            'sticker_3' => {'name' => 'Unicorn Sticker','value' =>'Unicorn Sticker'},
            'sticker_4' => {'name' => 'Heart Arrow Sticker','value' =>'Heart Arrow Sticker'},
            'sticker_5' => {'name' => 'Skull Sticker','value' =>'Skull Sticker'},
            'sticker_6' => {'name' => 'Hearts Sticker','value' =>'Hearts Sticker'},
            'sticker_7' => {'name' => 'Xoxo Sticker','value' =>'Xoxo Sticker'},
            'sticker_8' => {'name' => 'Feather Sticker','value' =>'Feather Sticker'},
            'sticker_9' => {'name' => 'Heart Wings Sticker','value' =>'Heart Wings Sticker'},
            'sticker_10' => {'name' => 'Arrow Sticker','value' =>'Arrow Sticker'},
            'sticker_11' => {'name' => 'LOL Sticker','value' =>'LOL Sticker'},
            'sticker_12' => {'name' => 'Heart 2 Sticker','value' =>'Heart 2 Sticker'},
            'sticker_13' => {'name' => 'Diamond Sticker','value' =>'Diamond Sticker'},
            'sticker_14' => {'name' => 'Peace Sticker','value' =>'Peace Sticker'},
            'sticker_15' => {'name' => 'Smiley Sticker','value' =>'Smiley Sticker'},
            'sticker_16' => {'name' => 'Feather 2 Sticker','value' =>'Feather 2 Sticker'},
            'sticker_17' => {'name' => 'OMG Sticker','value' =>'OMG Sticker'},
            'sticker_18' => {'name' => 'Hearts Doodle Sticker','value' =>'Hearts Doodle Sticker'},
            'sticker_19' => {'name' => 'Banner Sticker','value' =>'Banner Sticker'},
            'sticker_20' => {'name' => 'Thumbs Up Sticker','value' =>'Thumbs Up Sticker'},
            'sticker_21' => {'name' => 'Heart Sticker','value' =>'Heart Sticker'},
            'sticker_22' => {'name' => 'Football Sticker','value' =>'Football Sticker'},
            'sticker_23' => {'name' => 'Heart Express Sticker','value' =>'Heart Express Sticker'},
            'sticker_24' => {'name' => '3D diamond 1 Sticker','value' =>'3D diamond 1 Sticker'},
            'sticker_25' => {'name' => 'Fist Sticker','value' =>'Fist Sticker'},
            'sticker_26' => {'name' => 'Heart Pixel Sticker','value' =>'Heart Pixel Sticker'},
            'sticker_27' => {'name' => 'Word Cloud Grumble Sticker','value' =>'Word Cloud Grumble Sticker'}
        },
        'sticker_tab_4' => {
            'sticker_0' => {'name' => 'Frappuccino Sticker','value' =>'Frappuccino Sticker'},
            'sticker_1' => {'name' => 'Pineapple Sticker','value' =>'Pineapple Sticker'},
            'sticker_2' => {'name' => 'Cupcake Sticker','value' =>'Cupcake Sticker'},
            'sticker_3' => {'name' => 'Cat Fries Sticker','value' =>'Cat Fries Sticker'},
            'sticker_4' => {'name' => 'BBQ Sticker','value' =>'BBQ Sticker'},
            'sticker_5' => {'name' => 'Pie Sticker','value' =>'Pie Sticker'},
            'sticker_6' => {'name' => 'Doughnut Sticker','value' =>'Doughnut Sticker'},
            'sticker_7' => {'name' => 'Bacon n egg Sticker','value' =>'Bacon n egg Sticker'},
            'sticker_8' => {'name' => 'Sundae Sticker','value' =>'Sundae Sticker'},
            'sticker_9' => {'name' => 'Ketchup Hot Dog Sticker','value' =>'Ketchup Hot Dog Sticker'},
            'sticker_10' => {'name' => 'Soda Sticker','value' =>'Soda Sticker'},
            'sticker_11' => {'name' => 'Pizza Sticker','value' =>'Pizza Sticker'},
            'sticker_12' => {'name' => 'Soda Can Sticker','value' =>'Soda Can Sticker'},
            'sticker_13' => {'name' => 'Valentines Cupcake Sticker','value' =>'Valentines Cupcake Sticker'},
            'sticker_14' => {'name' => 'Apple Angry Sticker','value' =>'Apple Angry Sticker'},
            'sticker_15' => {'name' => 'Turkey Sticker','value' =>'Turkey Sticker'},
            'sticker_16' => {'name' => 'Taco 2 Sticker','value' =>'Taco 2 Sticker'},
            'sticker_17' => {'name' => 'Ice Cream Cone Sticker','value' =>'Ice Cream Cone Sticker'},
            'sticker_18' => {'name' => 'Ice Cream Tub Sticker','value' =>'Ice Cream Tub Sticker'},
            'sticker_19' => {'name' => 'Spoon Sticker','value' =>'Spoon Sticker'},
            'sticker_20' => {'name' => 'Cocoa Sticker','value' =>'Cocoa Sticker'},
            'sticker_21' => {'name' => 'Watermelon Sticker','value' =>'Watermelon Sticker'},
            'sticker_22' => {'name' => 'Candy Sticker','value' =>'Candy Sticker'},
            'sticker_23' => {'name' => 'Cat Coffee Sticker','value' =>'Cat Coffee Sticker'},
            'sticker_24' => {'name' => 'Fork Sticker','value' =>'Fork Sticker'},
            'sticker_25' => {'name' => 'Oranges Sticker','value' =>'Oranges Sticker'}
        },
        'sticker_tab_5' => {
            'sticker_0' => {'name' => 'Balloons 2 Sticker','value' =>'Balloons 2 Sticker'},
            'sticker_1' => {'name' => 'Cupcake Sticker','value' =>'Cupcake Sticker'},
            'sticker_2' => {'name' => 'Party Hat Sticker','value' =>'Party Hat Sticker'},
            'sticker_3' => {'name' => 'Banner Sticker','value' =>'Banner Sticker'},
            'sticker_4' => {'name' => 'Fireworks Sticker','value' =>'Fireworks Sticker'},
            'sticker_5' => {'name' => 'Stars Sticker','value' =>'Stars Sticker'},
            'sticker_6' => {'name' => 'Birthday Hat Sticker','value' =>'Birthday Hat Sticker'},
            'sticker_7' => {'name' => 'Gift Sticker','value' =>'Gift Sticker'},
            'sticker_8' => {'name' => 'Balloons Sticker','value' =>'Balloons Sticker'},
            'sticker_9' => {'name' => 'Cake Sticker','value' =>'Cake Sticker'},
            'sticker_10' => {'name' => 'Gift Dog Sticker','value' =>'Gift Dog Sticker'},
            'sticker_11' => {'name' => 'Cat Celebrate Sticker','value' =>'Cat Celebrate Sticker'},
            'sticker_12' => {'name' => 'Crown Sticker','value' =>'Crown Sticker'},
            'sticker_13' => {'name' => 'Horn Sticker','value' =>'Horn Sticker'}
        },
        'sticker_tab_6' => {
            'sticker_0' => {'name' => 'Cat Face Sticker','value' =>'Cat Face Sticker'},
            'sticker_1' => {'name' => 'Fox Sticker','value' =>'Fox Sticker'},
            'sticker_2' => {'name' => 'Rabbit Sticker','value' =>'Rabbit Sticker'},
            'sticker_3' => {'name' => 'Cat Fries Sticker','value' =>'Cat Fries Sticker'},
            'sticker_4' => {'name' => 'Cat Sticker','value' =>'Cat Sticker'},
            'sticker_5' => {'name' => 'Hedgehog Sticker','value' =>'Hedgehog Sticker'},
            'sticker_6' => {'name' => 'Scary Cat Sticker','value' =>'Scary Cat Sticker'},
            'sticker_7' => {'name' => 'Spider Sticker','value' =>'Spider Sticker'},
            'sticker_8' => {'name' => 'Dog Sticker','value' =>'Dog Sticker'},
            'sticker_9' => {'name' => 'Owl Sticker','value' =>'Owl Sticker'},
            'sticker_10' => {'name' => 'Cat on Head Sticker','value' =>'Cat on Head Sticker'},
            'sticker_11' => {'name' => 'Bird Envelope Sticker','value' =>'Bird Envelope Sticker'},
            'sticker_12' => {'name' => 'Sloth Sticker','value' =>'Sloth Sticker'},
            'sticker_13' => {'name' => 'Panda Sticker','value' =>'Panda Sticker'},
            'sticker_14' => {'name' => 'Cat Shock Sticker','value' =>'Cat Shock Sticker'},
            'sticker_15' => {'name' => 'Butterfly Sticker','value' =>'Butterfly Sticker'},
            'sticker_16' => {'name' => 'Bird Sticker','value' =>'Bird Sticker'},
            'sticker_17' => {'name' => 'Koala Sticker','value' =>'Koala Sticker'},
            'sticker_18' => {'name' => 'Cat Grumble Sticker','value' =>'Cat Grumble Sticker'},
            'sticker_19' => {'name' => 'Pig Sticker','value' =>'Pig Sticker'}
        },
         'sticker_tab_7' => {
            'sticker_0' => {'name' => 'Feather Sticker','value' =>'Feather Sticker'},
            'sticker_1' => {'name' => 'Rainbow 2 Sticker','value' =>'Rainbow 2 Sticker'},
            'sticker_2' => {'name' => 'Flowers Sticker','value' =>'Flowers Sticker'},
            'sticker_3' => {'name' => 'Moon Sticker','value' =>'Moon Sticker'},
            'sticker_4' => {'name' => 'Feather 2 Sticker','value' =>'Feather 2 Sticker'},
            'sticker_5' => {'name' => 'Hibiscus Sticker','value' =>'Hibiscus Sticker'},
            'sticker_6' => {'name' => 'Sun Sticker','value' =>'Sun Sticker'},
            'sticker_7' => {'name' => 'Heart Bouquet Sticker','value' =>'Heart Bouquet Sticker'},
            'sticker_8' => {'name' => 'Mushrooms Sticker','value' =>'Mushrooms Sticker'},
            'sticker_9' => {'name' => 'Flowers Sticker','value' =>'Flowers Sticker'},
            'sticker_10' => {'name' => 'Plum Blossom Sticker','value' =>'Plum Blossom Sticker'},
            'sticker_11' => {'name' => 'Sun Face Sticker','value' =>'Sun Face Sticker'},
            'sticker_12' => {'name' => 'Star Sticker','value' =>'Star Sticker'},
            'sticker_13' => {'name' => 'Cloud Sun Sticker','value' =>'Cloud Sun Sticker'},
            'sticker_14' => {'name' => 'Leaves Sticker','value' =>'Leaves Sticker'},
            'sticker_15' => {'name' => 'Rosebud Sticker','value' =>'Rosebud Sticker'},
            'sticker_16' => {'name' => 'Palm Tree Sticker','value' =>'Palm Tree Sticker'},
            'sticker_17' => {'name' => 'Stars Sticker','value' =>'Stars Sticker'},
            'sticker_18' => {'name' => 'Cloud Angry Sticker','value' =>'Cloud Angry Sticker'},
            'sticker_19' => {'name' => 'Palm Tree 2 Sticker','value' =>'Palm Tree 2 Sticker'},
            'sticker_20' => {'name' => 'Wave Sticker','value' =>'Wave Sticker'},
            'sticker_21' => {'name' => 'Star Yellow Sticker','value' =>'Star Yellow Sticker'},
            'sticker_22' => {'name' => 'Cloud Sad Sticker','value' =>'Cloud Sad Sticker'}
        },
        'sticker_tab_8' => {
            'sticker_0' => {'name' => 'Band aid 2 Sticker','value' =>'Band aid 2 Sticker'},
            'sticker_1' => {'name' => 'Letter Sticker','value' =>'Letter Sticker'},
            'sticker_2' => {'name' => 'Kleenex Sticker','value' =>'Kleenex Sticker'},
            'sticker_3' => {'name' => 'Measles Sticker','value' =>'Measles Sticker'},
            'sticker_4' => {'name' => 'Medicine Sticker','value' =>'Medicine Sticker'},
            'sticker_5' => {'name' => 'Love Monster Sticker','value' =>'Love Monster Sticker'}
        }

          }

           $frame ={ 
            'frame_0' => {'name' => 'Hearts Overlay Frame','value' =>'HeartsOverlayFrame'},
            'frame_1' => {'name' => 'Sloppy Frame','value' =>'SloppyFrame'},
            'frame_2' => {'name' => 'Rainbow Frame','value' =>'RainbowFrame'},
            'frame_3' => {'name' => 'White Frame','value' =>'WhiteFrame'},
            'frame_4' => {'name' => 'Stars Overlay Frame','value' =>'StarsOverlayFrame'},
            'frame_5' => {'name' => 'Polka Dots Frame','value' =>'PolkadotsFrame'},
            'frame_6' => {'name' => 'Grey Shadow Frame','value' =>'GreyShadowFrame'},
            'frame_7' => {'name' => 'Pink Triangle Frame','value' =>'PinkTriangleFrame'},
            'frame_8' => {'name' => 'White Rounded Frame','value' =>'WhiteRoundedFrame'},
            'frame_9' => {'name' => 'Floral 2 Frame','value' =>'Floral2Frame'},
            'frame_10' => {'name' => 'Blue Watercolor Frame','value' =>'BlueWatercoloFrame'},
            'frame_11' => {'name' => 'Floral Overlay Frame','value' =>'FloralOverlayFrame'},
            'frame_12' => {'name' => 'Red Frame','value' =>'RedFrame'},
            'frame_13' => {'name' => 'Gradient Frame','value' =>'GradientFrame'},
            'frame_14' => {'name' => 'Turquoise Frame','value' =>'TurquoiseFrame'},
            'frame_15' => {'name' => 'Dots Overlay Frame','value' =>'DotsOverlayFrame'},
            'frame_16' => {'name' => 'Kraft Frame','value' =>'KraftFrame'},
            'frame_17' => {'name' => 'White Bar Frame','value' =>'WhiteBarFrame'},
            'frame_18' => {'name' => 'Pink Spray Paint Frame','value' =>'PinkSpraypaintFrame'},
            'frame_19' => {'name' => 'White Full Frame','value' =>'WhiteFullFrame'}
        }
        $font ={ 
            'font_0' => {'name' => 'Aleo','value' =>'Aleo'},
            'font_1' => {'name' => 'BERNIER Regular','value' =>'BERNIERRegular-Regular'},
            'font_2' => {'name' => 'Blogger Sans','value' =>'BloggerSans-Light'},
            'font_3' => {'name' => 'Cheque','value' =>'Cheque-Regular'},
            'font_4' => {'name' => 'Fira Sans','value' =>'FiraSans-Regular'},
            'font_5' => {'name' => 'Gagalin','value' =>'Gagalin-Regular'},
            'font_6' => {'name' => 'Hagin Caps Thin','value' =>'Hagin'},
            'font_7' => {'name' => 'Panton','value' =>'Panton-LightitalicCaps'},
            'font_8' => {'name' => 'Panton','value' =>'Panton-LightitalicCaps'},
            'font_9' => {'name' => 'Perfograma','value' =>'Perfograma'},
            'font_10' => {'name' => 'Summer Font','value' =>'SummerFont-Light'},
            'font_11' => {'name' => 'American Typewriter','value' =>'American'},
            'font_12' => {'name' => 'Baskerville','value' =>'Baskerville'},
            'font_13' => {'name' => 'Bodoni 72','value' =>'BodoniSvtyTwoITCTT-Book'},
            'font_14' => {'name' => 'Bradley Hand','value' =>'Bradley'},
            'font_15' => {'name' => 'Chalkboard SE','value' =>'ChalkboardSE-Regular'},
            'font_16' => {'name' => 'DIN Alternate','value' =>'DIN'},
            'font_17' => {'name' => 'Helvetica Neue','value' =>'Helvetica'},
            'font_18' => {'name' => 'Noteworthy','value' =>'Noteworthy-Light'},
            'font_19' => {'name' => 'Snell Roundhand','value' =>'Snell'},
            'font_20' => {'name' => 'Thonburi','value' =>'Thonburi'}
                             
        }
           
    