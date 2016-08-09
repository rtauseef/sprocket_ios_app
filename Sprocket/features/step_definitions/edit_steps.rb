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
                end
            end
        end
    end
end


Then (/^I select Frame$/) do
    touch "IMGLYIconCollectionViewCell"
    sleep(STEP_PAUSE)
end

And(/^I should see the photo with the selected frame$/) do
    sleep(STEP_PAUSE)
     post_img_frame_width = query("UIImageView index:0").first["frame"]["width"]
    post_img_frame_height = query("UIImageView index:0").first["frame"]["height"]
    raise "Frame Not Applied!" unless post_img_frame_width > $curr_edit_img_frame_width && post_img_frame_height > $curr_edit_img_frame_height
end

And(/^I should see the photo with no frame$/) do
    post_img_frame_width = query("* id:'GestureImageView'").first["frame"]["width"]
    post_img_frame_height = query("* id:'GestureImageView'").first["frame"]["height"]
    raise "Frame Applied!" unless post_img_frame_width = $curr_img_frame_width && post_img_frame_height = $curr_img_frame_height
end

And(/^I should see the photo with the entered text$/) do
    sleep(STEP_PAUSE)
end





