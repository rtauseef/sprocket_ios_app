When /^I touch Share icon$/ do
      #touch("view marked:'Share.png'")
    touch("view marked:'Share'")
    sleep(STEP_PAUSE)
end


And /^I touch Print Queue$/ do
  sleep(WAIT_SCREENLOAD)
    $current_date=(Time.now.strftime("%B %e")).to_s
    $selected_template=query("collectionView marked:'TemplateCollectionView'",:accessibilityValue).first
    touch "label marked:'Print Queue'"
    #uia_tap_mark("Allow")
    #uia_tap_mark("Ok")
end

#When /^I cancel the share$/ do
    #touch("UIImageView index:10")
    #sleep(STEP_PAUSE)
#end

When /^I cancel the share$/ do
        device_name = get_device_name
    if device_name.to_s != 'iPad'
        touch("label marked:'Cancel'")
    else
        if element_exists("view marked:'description'")
            touch "view marked:'description'"
        else
            touch "UIButtonLabel text:'Text'"
        end
    end
    sleep(STEP_PAUSE)
end

Then (/^I select the share button$/) do
  wait_for_elements_exist("view marked:'Share'",:timeout=>MAX_TIMEOUT)
  touch("view marked:'Share'")
  sleep(STEP_PAUSE)
end



