
def take_screenshot (path, screen_name)
  screenshots_folder = File.expand_path path
  unless screenshots_folder.nil? or File.exists?(screenshots_folder)
    FileUtils.mkdir_p(screenshots_folder)
  end
  Dir.chdir  screenshots_folder
  screenshot_embed
  sleep(SLEEP_SCREENLOAD)
  Dir.open(screenshots_folder).each do |file_name|
    name = File.basename(file_name, ".png")
    if name.to_s.include? "screenshot"
      File.rename(file_name, "#{screen_name}.png")
    end
  end
end
def zip_file (path, zip_name, folder_name)
 
  zip_path = File.expand_path path
  Dir.chdir  zip_path
  if File.exist?(zip_name) == true
    File.delete(zip_name)
    sleep(WAIT_SCREENLOAD)
  end
  system "zip -r #{zip_name} #{folder_name}"
end
def remove_folder folder_name
  sleep(SLEEP_SCREENLOAD)
  if File.exist?("#{folder_name}") == true
   FileUtils.rm_rf(Dir.glob("#{folder_name}"))
  end
  sleep(WAIT_SCREENLOAD)
end
def select_rand_stic sticker_tab
  stic_count=$sticker[sticker_tab].length
  val= Random.rand(0...stic_count-1)
  stic_id = "sticker_" + "#{val}"
  return stic_id
end   
def change_language (app_name,os_version,sim_name)
  $os_version = os_version
  $sim_name = sim_name
  if app_name == "Sprocket"
      SimLocale.new.current_language "#{$os_version}","#{$sim_name}"
      $curr_language = $curr_language.to_s.strip
      if $flag == "language"    
        if $language != nil 
          if $language_locale[$language] != nil
            ios_locale = $language_locale[$language]['ios_locale_id']
            language_locale =ios_locale.split("_")
            language_locale = language_locale[0]
          else
            raise "Language not found!"
          end
        else
          ios_locale = $language_locale["English-US"]['ios_locale_id']
          language_locale ="en"
        end
        $list_loc=$language_arr[ios_locale]    
        if $curr_language != language_locale
          SimLocale.new.change_sim_locale "#{$os_version}","#{$sim_name}","#{ios_locale}"
          sleep(3.0)
        end
      else      
        if $curr_language != "en"
          SimLocale.new.change_sim_locale "#{$os_version}","#{$sim_name}","en_US"
        end
      end 
  end 
end

def select_frame item
  if item == "LOreal iOS Frame"
      item = "L\\'Oreal iOS Frame"
  end

  if (element_exists "view marked:'#{item.to_s}'")
    touch query("view marked:'#{item.to_s}'")
  else
    i = 0
    while i < 10 do      
      scroll("UICollectionView",:right)
      i = i + 1
        if i >= 7
            raise "Frame not found"
          end
      if (element_exists "view marked:'#{item.to_s}'")
        touch query("view marked:'#{item.to_s}'")
        break
      end
    end
  end
end

def select_sticker item

  if (element_exists "view marked:'#{item.to_s}'")
    touch query("view marked:'#{item.to_s}'")
  else
    i=0
    while i<2 do
      scroll("UICollectionView",:down)
        sleep(STEP_PAUSE)
      i=i+1

      if (element_exists "view marked:'#{item.to_s}'")
        touch query("view marked:'#{item.to_s}'")
        break
      else if i>=2
             raise "Sticker not found"
           end
      end
    end
  end
end

def select_font item  
  if (element_exists "IMGLYLabelCaptionCollectionViewCell marked:'#{item.to_s}'")
    touch query("IMGLYLabelCaptionCollectionViewCell marked:'#{item.to_s}'")
  else
    i = 0
    while i < 7 do      
      scroll("UICollectionView",:right)
        sleep(STEP_PAUSE)
      i = i + 1
        if i >= 7
            raise "Font not found"
          end
      if (element_exists "IMGLYLabelCaptionCollectionViewCell marked:'#{item.to_s}'")
        touch query("IMGLYLabelCaptionCollectionViewCell marked:'#{item.to_s}'")
        sleep(STEP_PAUSE)
        break
      end
    end
  end
end

def select_color item  
  if (element_exists "IMGLYColorCollectionViewCell marked:'#{item.to_s}'")
    touch query("IMGLYColorCollectionViewCell marked:'#{item.to_s}'")
  else
    i = 0
    while i < 5 do      
      scroll("UICollectionView",:right)
        sleep(STEP_PAUSE)
      i = i + 1
        if i >= 7
            raise "color not found"
          end
      if (element_exists "IMGLYColorCollectionViewCell marked:'#{item.to_s}'")
        touch query("IMGLYColorCollectionViewCell marked:'#{item.to_s}'")
        break
      end
    end
  end
end
 