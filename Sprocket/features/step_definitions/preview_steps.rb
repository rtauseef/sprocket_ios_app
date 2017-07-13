Then(/^I should see "(.*?)" button$/) do |element_id|
  #sleep(MIN_TIMEOUT)
    sleep(STEP_PAUSE)
  if element_id == "Grid mode"
    check_element_exists @current_page.grid_mode_check_button
  else
    if element_id == "List mode"
      check_element_exists @current_page.list_mode_button
    else
      if element_id == "Folder"
        check_element_exists @current_page.arrow_down
      else
        if element_id == "close"
          check_element_exists @current_page.close
        else
          raise "Invalid Option!"
        end
      end
    end
  end
end

When(/^I double tap on the picture$/) do
 # sleep(MIN_TIMEOUT)
    sleep(STEP_PAUSE)
  close_camera_popup
  #sleep(WAIT_SCREENLOAD)
    sleep(STEP_PAUSE)
  $curr_img_frame_width = query("* id:'GestureImageView'").first["frame"]["width"]
  $curr_img_frame_height = query("* id:'GestureImageView'").first["frame"]["height"]
  double_tap "* id:'GestureImageView'"
end

Then(/^I should see margins on top and bottom$/) do
  #sleep(WAIT_SCREENLOAD)
    sleep(STEP_PAUSE)
  $post_img_frame_width = query("* id:'GestureImageView'").first["frame"]["width"]
  $post_img_frame_height = query("* id:'GestureImageView'").first["frame"]["height"]
  raise "Margins not found" unless $post_img_frame_width < $curr_img_frame_width && $post_img_frame_height < $curr_img_frame_height

end

Then(/^I should see the original image without margins$/) do
  $post_img_frame_width = query("* id:'GestureImageView'").first["frame"]["width"]
  $post_img_frame_height = query("* id:'GestureImageView'").first["frame"]["height"]
  raise "Original Image not found" unless $post_img_frame_width > $curr_img_frame_width && $post_img_frame_height > $curr_img_frame_height
end
Then(/^I should not see margins on top and bottom$/) do
 # sleep(WAIT_SCREENLOAD)
    sleep(STEP_PAUSE)
  $post_img_frame_width = query("* id:'GestureImageView'").first["frame"]["width"]
  $post_img_frame_height = query("* id:'GestureImageView'").first["frame"]["height"]
  raise "Margins not found" unless $post_img_frame_width > $curr_img_frame_width && $post_img_frame_height > $curr_img_frame_height

end

Then(/^I should see the original image with margins$/) do
  $post_img_frame_width = query("* id:'GestureImageView'").first["frame"]["width"]
  $post_img_frame_height = query("* id:'GestureImageView'").first["frame"]["height"]
  raise "Original Image not found" unless $post_img_frame_width < $curr_img_frame_width && $post_img_frame_height < $curr_img_frame_height
end
When(/^I pinch "(.*?)" on the picture$/) do |in_out|
  $curr_img_frame_width = query("* id:'GestureImageView'").first["frame"]["width"]
  pinch("#{in_out}", { query: "* id:'GestureView'" })
end

Then(/^I should see it in "(.*?)" size$/) do |size|
  $post_img_frame_width = query("* id:'GestureImageView'").first["frame"]["width"]
  if size == "bigger"
      raise "Image not zoomed in!" unless $post_img_frame_width > $curr_img_frame_width
  else
      raise "Image not zoomed out!" unless $post_img_frame_width < $curr_img_frame_width
  end
end

Then(/^I should see the preview-drawer "(.*?)"$/) do |drawer_move|
    post_img_frame_width = query("* id:'GestureImageView'").first["frame"]["width"]
    post_img_frame_height = query("* id:'GestureImageView'").first["frame"]["height"]
    if drawer_move == "slides up"
        raise "Drawer not found" unless post_img_frame_width < $curr_img_frame_width && post_img_frame_height < $curr_img_frame_height
    else
        raise "Drawer not closed" unless post_img_frame_width == $curr_img_frame_width && post_img_frame_height == $curr_img_frame_height
    end
end

And(/^I should see "(.*?)" with "(.*?)" items and a right arrow$/) do |print_queue, number|
    check_element_exists(@current_page.printqueue)
    check_element_exists("view marked:'#{number}'")
    check_element_exists("* id:'Arrow_Right'")
   # sleep(STEP_PAUSE)
end

Then(/^I should see "([^"]*)" mark with "([^"]*)" button enabled$/) do |copy, change_copy|
    $num = copy.gsub(' Copy','').gsub(' Copies','')
    check_element_exists("view marked:'#{copy}'")
    if change_copy == "Increment"
        check_element_exists "* id:'+ButtonEnabled'"
    end
   # sleep(STEP_PAUSE)
end

Then(/^I should see the number of copies "(.*?)"$/) do |copies|
    if copies == "incremented"
        num_copies = $num.to_i
        incr_num = num_copies + 1
        copies_incr = query("UILabel index:1", :text)[0].gsub(' Copy','').gsub(' Copies','')
        $copies_incr = copies_incr.to_i
        raise "Copies not incremented" unless incr_num == $copies_incr
    else
        num_copies = $copies_incr
        incr_num = num_copies - 1
        copies_incr = query("UILabel index:1", :text)[0].gsub(' Copy','').gsub(' Copies','')
        copies_incr = copies_incr.to_i
        raise "Copies not incremented" unless incr_num == copies_incr
    end
end



