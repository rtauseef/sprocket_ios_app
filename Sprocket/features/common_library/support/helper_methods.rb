require 'securerandom'

def page_by_name page_name
  page_class_name = "#{page_name.gsub(' ', '')}Screen"
  page_constant = Object.const_get(page_class_name)

  page(page_constant)
end


def scroll_view_position
  position_attribute = "contentOffset: "
  scrollview_attributes = query("scrollView").first["description"]

  attribute_value_index = scrollview_attributes.index(position_attribute) + position_attribute.length
  scrollview_attributes = scrollview_attributes[attribute_value_index, 99]
  scrollview_attributes = scrollview_attributes[0, scrollview_attributes.index(">")]

  scrollview_attributes
end

def go_to page_class
  requested_page = page(page_class).navigate

  #wait_for_none_animating
  requested_page
end

def moveToFirst
  value = query("UICollectionView",numberOfItemsInSection:0).first
  indexToFind = 0
  for index in 0..value - 1
    if query("UICollectionViewCell index:#{index} descendant label marked:'label'").empty? == true
      indexToFind = index
      scroll_to_collection_view_item(indexToFind,0,{:scroll_position => :center_horizontal, :animate => true})
      sleep 1
      break
    end
  end
end

def check_tables_exist item
	if item.kind_of?(Array)
		item.each do |subitem|
		check_tables_exist subitem
	end
	else
		check_element_exists "all view marked:'#{item.to_s}'"
	end
end


def check_elements_exist item
  if item.kind_of?(Array)
    item.each do |subitem|
      check_elements_exist subitem
    end
  else
    $cnt = 0
    moveToFirst
    while (element_does_not_exist "view marked:'#{item.to_s}'") do
      sleep(0.5)
      indexLastItem = query("UICollectionView label").length - 1
      $cnt = $cnt + 1
      if $cnt == 16
        raise "template not found"
        $cnt = -1
        $currentItem = ""
        return
      end
      break if $cnt == -1
      indexLastItem = query("UICollectionView label").length - 1
      $currentItem = query("UILabel label index:#{indexLastItem}", :text)[0]
      scroll("collectionView", :right)
	  sleep(WAIT_SCREENLOAD)
    end
    wait_for_elements_exist("view marked:'#{item.to_s}'", :timeout => MAX_TIMEOUT)
  end
end

def check_item_exist item
  if item.kind_of?(Array)
    item.each do |subitem|
      check_item_exist subitem

    end
  else
      if (element_does_not_exist "view marked:'#{item.to_s}'")
            scroll("tableView", :down)
            sleep(STEP_PAUSE)
      end
    while (element_does_not_exist "view marked:'#{item.to_s}'") do
      sleep(STEP_PAUSE)
     raise "#{item.to_s} not found"
    end
    wait_for_elements_exist("view marked:'#{item.to_s}'", :timeout => 10)
  end
end



def first_from array
  array.first
end

def font_size_from selector
  value = first_from query selector, :font, :fontDescriptor, objectForKey:'NSFontSizeAttribute'
  value.round 4
end

def font_from selector
  first_from query selector, :font, :fontName
end



def pause
  sleep(STEP_PAUSE)
end

def swipe_coach_marks_view
  if element_exists("PGSwipeCoachMarksView")
    a = send_uia_command :command => "target.rect().size.width"
    send_uia_command :command => "target.dragFromToForDuration({x:50.00, y:200.00}, {x:(#{a['value']}*0.9), y:200.00}, 1)"
    sleep(0.5)
  end
end

def close_survey
  survey_message=uia_query :view, marked:'No, thanks'
  if survey_message.length >0
    uia_tap_mark("No, thanks")
  end
  sleep(WAIT_SCREENLOAD)
end

def instagram_auth_button
  "webView css:'input' index:1"
end

def check_spinner_exists
  if element_exists("view marked:'In progress'")
    sleep(SPINNER_TIMEOUT)
  end
end

def get_os_version
  splitdevTarg = ENV['DEVICE_TARGET'].split(" ")
      os_index = splitdevTarg.index{|s| s.include?("(")}
     os_version = splitdevTarg[os_index].gsub('(','').gsub(')','')
      return os_version
end

def get_device_name
  splitdevTarg = ENV['DEVICE_TARGET'].split(" ")
  device_name = splitdevTarg[0]
  return device_name
end

def get_device_type
  splitdevTarg = ENV['DEVICE_TARGET'].split(" ")
  os_index = splitdevTarg.index{|s| s.include?("(")}
    if os_index > 2
        device_type = splitdevTarg[1] + splitdevTarg[2]
    else
        device_type = splitdevTarg[1]
    end    
  return device_type  
end

def check_page_loaded social_media
  check_spinner_exists
  if element_exists(social_media)
    #Break
  else if element_exists(("view marked:'Alert Strip Message Label'")&&("button marked:'Alert Strip Action Button'"))
         touch("button marked:'Alert Strip Action Button'")
         sleep(SPINNER_TIMEOUT)
         if element_exists(social_media)
           #Break
         else
           raise "page not loaded on retry"
         end
       else
         raise "Retry not loaded!"
       end
  end

end

def find_printer printername
    sleep(STEP_PAUSE)
  if get_os_version.to_f < 8.0
    #touch("view marked:'Print'")
      sleep(STEP_PAUSE)
    #touch("view marked:'Select Printer'")
    touch("view marked:'Printer'")
  else
    if element_exists("view marked:'Printer'")
      touch("view marked:'Printer'")
    else
      touch("view marked:'Settings'")
      sleep(STEP_PAUSE)
      touch("view marked:'Printer'")
    end
  end
  sleep(STEP_PAUSE)
  pcname = gethostname
  # Get array of table rows and find it's count
  arrRows = query("tableViewCell label")
  rowCount = arrRows.length

  expPageCount = 25

  until rowCount < 0
    if query("tableViewCell label index:#{rowCount}", :text).first==pcname
      if query("tableViewCell label index:#{rowCount-1}", :text).first==printername
       
         sleep(WAIT_SCREENLOAD)
        touch("UITableViewCell label index:#{rowCount-1}")
        break;
      end
    end

    rowCount=rowCount-1
    if rowCount==0
      scroll("tableView", :down)
      sleep(WAIT_SCREENLOAD)
      arrRows = query("tableViewCell label")
      rowCount = arrRows.length
      expPageCount = expPageCount - 1
      if expPageCount == 0
        rowCount = -1
        break;
      end
    end
  end

  if rowCount < 0
    raise "No such printer with name #{printername} found"
  end

end


def get_random_name
    random_name = SecureRandom.random_number(36**12).to_s(36).rjust(12, "0")
    return random_name
    end
def get_xcode_version
    xcode_build_version = %x( xcodebuild -version ).split(" ")
    xcode_version = xcode_build_version[1]
    return xcode_version
end
def get_udid 
    sim_os=get_os_version.tr!('.','-')
    if get_device_type == "6Plus"
        device_type = "6"+ " " +"Plus"
    else
        device_type = get_device_type
    end
    sim_name = get_device_name + " " + device_type
    sim_path=""
    found=false
    #get home folder
    home_folder=`echo ~`.strip

    #navigate to core devices folder
    core_devices="#{home_folder}/Library/Developer/CoreSimulator/Devices"
    `cd #{core_devices}`
    #list all dirs
    all_sims=Dir["#{core_devices}/*"]
    all_sims.each do |each_sim|
    sim_info = Plist::parse_xml("#{each_sim}/device.plist")
            if sim_info["name"] == sim_name && sim_info["runtime"].match(sim_os)   
            $udid = sim_info["UDID"]
            found=true
            break
        end
    end
    return $udid
  end

