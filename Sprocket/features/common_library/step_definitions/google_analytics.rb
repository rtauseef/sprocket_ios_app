And(/^I verify log for "Landing" screen$/) do
  if checkhomepage != "true"
    raise ("Verification failed")
  end
end

And(/^I verify log for "Categories" screen$/) do
    if checkhomepage != "true"
       raise ("Verification failed")
    end
end

And(/^I check log for selected category as "(.*?)"$/) do |template|
   val = checktemplate "#{template}"
    if val == "false"
         raise ("Verification failed")
    end
end

And(/^Fetch Xcode Console Log$/) do
  fetch_Xcodelog
end

And(/^I check log for selected template as "(.*?)"$/) do |template|
  val = checktemplate "#{template}"
  if val == "false"
    raise ("Verification failed")
  end
end

And(/^I verify log for camera roll$/) do
  if checkcameraroll != "true"
    raise ("Verification failed")
  end
end

And(/^I verify log for "Print" and selected paper size "(.*?)"$/) do |paper_size|
  val = checkprint "#{paper_size}"
  if val == "false"
    raise ("Verification failed")
  end
end

And(/^I verify log for "Print" and selected paper type "(.*?)"$/) do |paper_type|
  val = checktype "#{paper_type}"
  if val == "false"
    raise ("Verification failed")
  end
end

Then(/^I cancel print$/) do
  sleep(STEP_PAUSE)
  touch("label text:'Cancel'")
end

And (/^I verify log for print cancelled$/) do
  if cancelprint != "true"
    raise ("Verification failed")
  end
end




