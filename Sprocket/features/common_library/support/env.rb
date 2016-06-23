MIN_TIMEOUT = (ENV['MAX_TIMEOUT'] || 2).to_f
MAX_TIMEOUT = (ENV['MAX_TIMEOUT'] || 20).to_f
WAIT_SCREENLOAD = (ENV['WAIT_SCREENLOAD'] || 3).to_f
SOCIALMEDIA_TIMEOUT = (ENV['SOCIALMEDIA_TIMEOUT'] || 60).to_f
SLEEP_SCREENLOAD = (ENV['SLEEP_SCREENLOAD'] || 10).to_f
SLEEP_MAX = (ENV['SLEEP_MAX'] || 30).to_f
SPINNER_TIMEOUT= (ENV['SPINNER_TIMEOUT'] || 13).to_f
SLEEP_MIN = (ENV['SLEEP_MIN'] || 0.5).to_f

require 'calabash-cucumber/cucumber'
require 'fileutils'

private

local_path = File.expand_path(__FILE__)
path = File.join(local_path, "../../../screenshots")
screenshots_folder = File.expand_path path

if not File.exist? screenshots_folder
    FileUtils::mkdir screenshots_folder
end

