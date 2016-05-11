Then(/^I should see "(.*?)" logo$/) do |arg|
    if arg=="Instagram"
       check_element_exists("view marked:'LoginInstagram.png'")
    else if arg=="Facebook"
        check_element_exists("view marked:'LoginFacebook.png'")
    else if arg=="Flickr"
        check_element_exists("view marked:'LoginFlickr.png'")
    else 
        check_element_exists("view marked:'LoginCameraRoll.png'")
    end
    end
    end
    
end
