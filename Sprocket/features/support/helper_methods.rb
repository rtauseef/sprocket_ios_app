
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
  end
  system "zip -r #{zip_name} #{folder_name}"
end
def remove_folder folder_name
  sleep(10.0)
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