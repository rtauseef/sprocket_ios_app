When /^I touch the text area on image$/ do
  touch("textView marked:'description'")
  sleep(STEP_PAUSE)
end

When /^I enter description$/ do
  clear_text("textView marked:'description'")
  @current_page.text_edit('lovely pic')
  sleep(STEP_PAUSE)
end

And /^I should see description in the text box$/ do
  query("textView marked:'description'",:text)=='lovely pic'
  sleep(STEP_PAUSE)
end