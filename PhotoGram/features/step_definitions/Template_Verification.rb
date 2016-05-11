Then /^I touch the text box$/ do
   touch("* id:'description'")
   sleep(STEP_PAUSE)
end

Then /^I should see "(.*?)" in the text box$/ do |text|
   sleep(SLEEP_SCREENLOAD)
    message =query("* id:'description'", :text).first
   
    unless text.eql? message
        raise "Text not found. Expected '#{text}', found '#{message}'"
    end

    sleep(STEP_PAUSE)
end

Then (/^I "([^"]*)" all templates in "([^"]*)" paper size with "([^"]*)" printer$/) do |share_option,paper_size, printer_name|
  sleep(5.0)
  template_name=["Hemingway", "Kerouac", "Asimov", "Lovecraft", "Wallace", "Ariel", "Sofia", "Jack", "Steinbeck", "Dickens", "Clean"]
  i = 0
  while i < 11
    macro %Q|I touch the "#{template_name[i]}" template|
    macro %Q|the template "#{template_name[i]}" should be selected|
    macro %Q|I touch Share icon|
    macro %Q|I touch "#{share_option}"|
    macro %Q|I run print simulator|
    macro %Q|I scroll screen "down"|
    macro %Q|I should see the paper size options|
    macro %Q|I selected the paper size "#{paper_size}"|
    macro %Q|I scroll down until "#{printer_name}" is visible in the list|
    macro %Q|I wait for some seconds|
    macro %Q|I choose print button|
    macro %Q|I wait for some seconds|
    macro %Q|I delete printer simulater generated files|
    i= i + 1
    sleep(SLEEP_SCREENLOAD)
  end
end

