And (/^I check the paper size is "([^\"]*)" from log$/) do |size|

  val_x = get_configvalue(size , "x")
  val_y = get_configvalue(size , "y")
  compare  = ($mertics_details['paper_size-x'] == val_x) ?  true : false
  raise "paper size verification failed" unless compare==true
  compare  = ($mertics_details['paper_size-y'] == val_y) ?  true : false
  raise "paper size verification failed" unless compare==true
  compare  = ($mertics_details['resolution'] == "600") ?  true : false
  raise "paper size verification failed" unless compare==true
end

And (/^I check paper size sensor of printer "([^\"]*)"$/) do |printer_name|
  check_paper_size "#{printer_name}"
end

And (/^I uncheck paper size sensor of printer "([^\"]*)"$/) do |printer_name|
  uncheck_paper_size "#{printer_name}"
end

Then (/^I clear log in printer stimulator$/) do
  clear_printersimulatorlog
end

Then (/^I save log of printer simulator$/) do
  save_printersimulatorlog
end

Then (/^Fetch values from printer simulator log$/) do
  printlog = get_logvalues
  $mertics_details = printlog
end

Then (/^I compare generated PDF with the template$/) do
  diff = comparepdf
  if diff != "0 (0)"
    raise "Comparison failed"
  else
    #puts "No difference between file generated and template"
  end
end
