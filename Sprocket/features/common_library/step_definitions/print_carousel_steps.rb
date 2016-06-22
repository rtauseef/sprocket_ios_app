Then(/^I should see the page number as "(.*?)"$/) do |page_no|
      text_data=query("label marked:'#{page_no.to_s}'")
    raise "Wrong page number!" unless text_data.length > 0
end
Then(/^I check carousal view is present$/) do
    multipage_button=query("* id:'MPSelected'")
  raise "Carousel view not found!" unless multipage_button.length > 0
end
Given(/^I select "(.*?)" multipage PDF$/) do |pdf_name|
  $pdf_name = pdf_name
    macro %Q|I scroll screen to find "#{pdf_name}"|
    macro %Q|I touch "#{pdf_name}"|
end
Then(/^I check page no for pages$/) do
    split_pdfname = $pdf_name.split(" ")
    page_count = split_pdfname[0].to_i
    $page_count = page_count
    index = 1
    while page_count > 0
        page_no = (index+1).to_s + " " + "of" + " " + $page_count.to_s
    break if index == $page_count
        macro %Q|I do a long swipe to the "left" direction|
        sleep(STEP_PAUSE)
        macro %Q|I should see the page number as "#{page_no}"|
        sleep(STEP_PAUSE)
        page_count = page_count - 1
        index = index + 1
    end
    while index > 0
        page_no = (index-1).to_s + " " + "of" + " " + $page_count.to_s
    break if index == 1
        macro %Q|I do a long swipe to the "right" direction|
         sleep(STEP_PAUSE)
        touch "scrollView"
        sleep(STEP_PAUSE)
        macro %Q|I should see the page number as "#{page_no}"|
        index = index - 1
    end
end

Then(/^I verify print job details$/) do
    if $product_id == "Card Editor"
        $print_details = ["2 Copies / 5 x 7 Photo Paper","1 Copy / 5 x 7 Photo Paper"]
    else
        $print_details = ["2 Copies / 4 x 6 Photo Paper","1 Copy / 4 x 6 Photo Paper"]
    end
    print_job_count =2 
    index = 0
    
    while print_job_count >0
        sleep(STEP_PAUSE)
        template_name = query("label marked:'#{$name_array[print_job_count-1].to_s}'")
        summary_details=query("label marked:'#{$print_details[print_job_count-1].to_s}'")
        raise "summary not correct!" unless template_name.length >0 && summary_details.length > 0
    break if print_job_count == 1
        macro %Q|I do a long swipe to the "left" direction|
        touch "scrollView"
        print_job_count = print_job_count - 1
    end
    
    while index < 2
        template_name = query("label marked:'#{$name_array[index].to_s}'")
        summary_details=query("label marked:'#{$print_details[index].to_s}'")
        raise "summary not correct!" unless template_name.length >0 && summary_details.length > 0
    break if index == 1
        macro %Q|I do a long swipe to the "right" direction|
        touch "scrollView"
        index = index + 1
    end
    
    
end