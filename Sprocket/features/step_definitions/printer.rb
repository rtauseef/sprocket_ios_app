Then(/^I should see the message to pair the device with the bluetooth printer$/) do
    check_element_exists @current_page.message_title
    sleep(STEP_PAUSE)
end

And(/^I should see the modal screen with the message to connect the printer$/) do
    check_element_exists @current_page.modal_title
    sleep(STEP_PAUSE)
end

And(/^I should see the modal screen title$/) do
    check_element_exists @current_page.modal_title
    sleep(STEP_PAUSE)
end

And(/^I should see the modal screen content$/) do
    check_element_exists @current_page.modal_content
    sleep(STEP_PAUSE)
end

And(/^I should see the button "(.*?)"$/) do |button|
    check_element_exists("label {text CONTAINS '#{button}'}")
    sleep(STEP_PAUSE)
end

And(/^I tap the "OK" button$/) do
    touch "label {text CONTAINS 'OK'}"
    sleep(STEP_PAUSE)
end

Then(/^I should not see the modal screen$/) do
    check_element_does_not_exist @current_page.modal_title
    sleep(STEP_PAUSE)
end