AfterStep do |scenario|
  if (scenario.failed?)
    take_screenshots = ENV['TAKE_SCREENSHOTS']

    unless take_screenshots.nil? or take_screenshots.to_i.zero?
      screenshots_folder = ENV['SCREENSHOT_PATH']

      unless screenshots_folder.nil? or File.exists?(screenshots_folder)
        FileUtils.mkdir_p(screenshots_folder)
      end

      screenshot_embed
    end
  end
end