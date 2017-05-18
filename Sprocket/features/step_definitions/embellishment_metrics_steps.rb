#Reference- print_confirm_simulator is renamed to print_metrics
require 'json'
require 'open-uri'
require 'set'


Then (/^I Fetch embellishment metrics details$/) do
    sleep(SLEEP_SCREENLOAD)
    app_name = get_app_name
    if app_name == "Sprocket"
        #hash = `curl -x "http://proxy.atlanta.hp.com:8080" -L "http://hpmobileprint:print1t@print-metrics-test.twosmiles.com/api/v1/mobile_app_metrics?today&size=1"`
        hash = `curl -L "http://hpmobileprint:print1t@print-metrics-test.twosmiles.com/api/v1/sprocket_embellishments?mobile_app_metrics_id=#{$metrics_id.to_i}"`
        hash = JSON.parse(hash)
        $embellish_metrics_details = hash
        puts $metrics_id
    end
end

Then(/^I verify the "([^"]*)" metrics length is "([^"]*)"$/) do |metrics_type, metrics_count|
  compare =(metrics_count.to_i == $embellish_metrics_details.length) ? true : false
   raise "Embellishment metrics count verification failed!" unless compare == true
end
Then(/^I verify the sticker names$/) do
  metrics_stic_arr= []
  i =0
  while i < $embellish_metrics_details.length
    metrics_stic_arr.push("#{$embellish_metrics_details[i]['name']}")
    i = i + 1
  end  
  compare = (($stic_arr.to_set.length == metrics_stic_arr.to_set.length)&&(($stic_arr.to_set - metrics_stic_arr.to_set).empty? == true)) ?true : false
  raise "Name verification failed!" unless compare == true
 end
Then(/^I verify the category is "([^"]*)"$/) do |category|
i = 0
while i < $embellish_metrics_details.length
  raise "Category verification failed!" unless $embellish_metrics_details[i]['category'] == category
  i = i+ 1
end
end