#Reference- print_confirm_simulator is renamed to print_metrics
require 'json'
require 'open-uri'
require 'set'


Then (/^I Fetch embellishment metrics details$/) do
    sleep(SLEEP_SCREENLOAD)
    app_name = get_app_name
    if app_name == "Sprocket"
        #hash = `curl -x "http://proxy.atlanta.hp.com:8080" -L "http://hpmobileprint:print1t@print-metrics-test.twosmiles.com/api/v1/sprocket_embellishments?mobile_app_metrics_id=#{$metrics_id.to_i}"`
        hash = `curl -L "http://hpmobileprint:print1t@print-metrics-test.twosmiles.com/api/v1/sprocket_embellishments?mobile_app_metrics_id=#{$metrics_id.to_i}"`
        hash = JSON.parse(hash)
        $embellish_metrics_details = hash
        
    end
end

Then(/^I verify the "([^"]*)" metrics length is "([^"]*)"$/) do |metrics_type, metrics_count|
  compare =(metrics_count.to_i == $embellish_metrics_details.length) ? true : false
  raise "Embellishment metrics count verification failed!" unless compare == true
end

Then(/^I verify "([^"]*)" of "([^"]*)" is "([^"]*)"$/) do |metrics_variable, metrics_index, metrics_value| 
  metrics_index =  metrics_index.split('-')
  metrics_index = metrics_index[1]
  metrics_index = metrics_index.to_i - 1
  if metrics_variable == "name"
    if metrics_value.include? "sticker"
      compare_name = ($embellish_metrics_details[metrics_index]['name'] == $stic_arr[metrics_index]) ? true : false
    else
      if metrics_value.include? "frame"
        compare_name = ($embellish_metrics_details[metrics_index]['name'] == $frame_name) ? true : false
      else
        compare_name = ($embellish_metrics_details[metrics_index]['name'] == metrics_value.strip) ? true : false
      end
    end
    raise "Name verification failed!" unless compare_name == true
  end
  if metrics_variable == "category"
    compare = ($embellish_metrics_details[metrics_index]['category'] == metrics_value.strip) ? true : false
    raise "Category verification failed!" unless compare == true
  end
end