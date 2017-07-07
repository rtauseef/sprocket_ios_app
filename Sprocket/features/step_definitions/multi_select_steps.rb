Then(/^I should see the multiselect option enabled$/) do
    check_element_exists(@current_page.multi_select 1)
    sleep(STEP_PAUSE)
end

Then(/^I select "(.*?)" photos$/) do |number|
    i = 0
    while i < number.to_i
        touch @current_page.multi_select i
        i = i + 1
    end
end

And(/^I should see the number of photos selected as "(.*?)"$/) do |number|
    sleep(STEP_PAUSE)
    check_element_exists(@current_page.number_of_photos number)
    $number = number
    sleep(STEP_PAUSE)
end

Then(/^I tap on the multi selected number$/) do
    touch @current_page.number_of_photos $number

end

Then(/^I should see the count of images and checkmark circle in each page when swipe "(.*?)"$/) do |side|
    sleep(WAIT_SCREENLOAD)
    if side == "left"
        i = 1
        while i < $number.to_i
            check_element_exists("view marked:'#{i} of #{$number}'")
            check_element_exists(@current_page.checkmark)

            swipe :left, :offset => {:x => 123, :y => 30}
            sleep(STEP_PAUSE)
            i = i + 1
        end
    else
        i = $number.to_i
        while i > 1
            check_element_exists("view marked:'#{i} of #{$number}'")
            check_element_exists(@current_page.checkmark)
            swipe :right, :offset => {:x => -100, :y => 120}
            sleep(STEP_PAUSE)
            i = i - 1
        end
    end
end
