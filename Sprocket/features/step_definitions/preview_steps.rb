Then(/^I should see "(.*?)" button$/) do |element_id|
    sleep(MIN_TIMEOUT)
  if element_id == "camera"
    check_element_exists @current_page.camera
  else
    if element_id == "cancel"
      check_element_exists @current_page.cancel
    else
      if element_id == "edit"
        check_element_exists @current_page.edit
      else
        if element_id == "print"
          check_element_exists @current_page.print
        else
          if element_id == "Grid mode"
            check_element_exists @current_page.grid_mode_check_button
          else
            if element_id == "List mode"
              check_element_exists @current_page.list_mode_button
            else
              if element_id == "Folder"
                check_element_exists @current_page.folder_icon
              else
                check_element_exists @current_page.share
              end
            end
          end
        end
      end
    end
  end
end

When(/^I double tap on the picture$/) do
  sleep(MIN_TIMEOUT)
  close_camera_popup
  sleep(WAIT_SCREENLOAD)
  $curr_img_frame_width = query("* id:'GestureImageView'").first["frame"]["width"]
  $curr_img_frame_height = query("* id:'GestureImageView'").first["frame"]["height"]
  double_tap "* id:'GestureImageView'"
end

Then(/^I should see margins on top and bottom$/) do
  sleep(WAIT_SCREENLOAD)
  $post_img_frame_width = query("* id:'GestureImageView'").first["frame"]["width"]
  $post_img_frame_height = query("* id:'GestureImageView'").first["frame"]["height"]
  raise "Margins not found" unless $post_img_frame_width < $curr_img_frame_width && $post_img_frame_height < $curr_img_frame_height

end

Then(/^I should see the original image without margins$/) do
  $post_img_frame_width = query("* id:'GestureImageView'").first["frame"]["width"]
  $post_img_frame_height = query("* id:'GestureImageView'").first["frame"]["height"]
  raise "Original Image not found" unless $post_img_frame_width > $curr_img_frame_width && $post_img_frame_height > $curr_img_frame_height
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