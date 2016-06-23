#steps from print_image_comparison

Then(/^I run the tshark to monitor the print job$/) do
  info = run_tshark
  raise "Failed to run the tshark" unless info['status']=='done'
  sleep(STEP_PAUSE)
end


And(/^I stop the wireshark execution$/) do
  stop = stop_tshark
  raise "failed to stop the execution of wireshark" unless stop['status'] =='stopped'
  sleep(STEP_PAUSE)
end

Then(/^I am verifying the "(.*?)" paper size$/) do |papersize|
  @printjob = get_printjob_attr
  size_y = @printjob['y-dimension'] #"15240" for size 4
  size_x = @printjob['x-dimension'] #"10160" for size 5
  @config = get_config_data
  conf_inf = @config['papersize']
  given_size_x = conf_inf[papersize+"-x"]
  given_size_y = conf_inf[papersize+"-y"]

  raise "Failed to verify #{papersize} paper size " unless (size_x.to_i == given_size_x.to_i) && (size_y.to_i == given_size_y.to_i)
  sleep(STEP_PAUSE)
end

Then(/^I am verifying the border borderless$/) do
  @printjob = get_printjob_attr
  media_bottom_margin= @printjob['media-bottom-margin']
  media_top_margin= @printjob['media-top-margin']
  media_left_margin= @printjob['media-left-margin']
  media_right_margin= @printjob['media-right-margin']

  raise "Failed to verify border borderless " unless (media_bottom_margin.to_i == 0) && (media_top_margin.to_i == 0) && (media_left_margin.to_i == 0) && (media_right_margin.to_i == 0)
  sleep(STEP_PAUSE)
end

Then(/^I am verifying the border$/) do
  @printjob = get_printjob_attr
  media_bottom_margin= @printjob['media-bottom-margin']
  media_top_margin= @printjob['media-top-margin']
  media_left_margin= @printjob['media-left-margin']
  media_right_margin= @printjob['media-right-margin']

  raise "Border missing " unless (media_bottom_margin.to_i > 0) && (media_top_margin.to_i > 0) && (media_left_margin.to_i > 0) && (media_right_margin.to_i > 0)
  sleep(STEP_PAUSE)
end


Then(/^verifying the paper type "(.*?)"$/) do |papertype|
  type = @printjob['quality']
  type = type.split(":")
  conf = @config['papertype']
  paper_type = conf[papertype]
  raise "Failed to verify #{papertype} paper type " unless type[1].to_i == paper_type.to_i
  sleep(STEP_PAUSE)
end



