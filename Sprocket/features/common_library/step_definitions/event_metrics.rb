#Reference- print_confirm_simulator is renamed to print_metrics
require 'json'
require 'open-uri'


Then (/^I Fetch event metrics details$/) do
    sleep(SLEEP_SCREENLOAD)
    
    if $product_id == "PrintPod"
       hash = `curl -x "http://proxy.atlanta.hp.com:8080" -L "http://hpmobileprint:print1t@print-metrics-test.twosmiles.com/api/v2/events?os_type="ios"&&print_library_version=#{$print_library_version}"`
        #hash = `curl -L "http://hpmobileprint:print1t@print-metrics-test.twosmiles.com/api/v2/events?os_type="ios"&&print_library_version=#{$print_library_version}"`
        hash = JSON.parse(hash)
        $mertics_array = hash
        if $mertics_array.length > 1
            $mertics_details = hash[$mertics_array.length - 1]
        else
            $mertics_details = hash[0]
        end
    end
end

Then(/^I check the print session id is "(.*?)"$/) do |print_session_id|
  compare = ($mertics_details['print_session_id'] == print_session_id) ?  true : false
  raise "Print_session_id verification failed!" unless compare==true
end

Then(/^I check the event count is "(.*?)"$/) do |event_count|
compare = ($mertics_details['event_count'] == event_count) ?  true : false
  raise "Event_count verification failed!" unless compare==true
end

Then(/^I check the event type id is "(.*?)"$/) do |event_type|
 compare = ($mertics_details['event_type_id'] == event_type) ?  true : false
  raise "Event_type verification failed!" unless compare==true
end
Then(/^I navigate to page settings screen$/) do
    macro %Q|I am on the "PrintPod" screen|
    macro %Q|I wait for some seconds|
    macro %Q|I touch "Share Item"|
    macro %Q|I touch "5x7 portrait"|
    macro %Q|I wait for some seconds|
    macro %Q|I touch "Print"|
    
end