########################################
#                                      #
#       Important Note                 #
#                                      #
#   When running calabash-ios tests at #
#   www.xamarin.com/test-cloud         #
#   this file will be overwritten by   #
#   a file which automates             #
#   app launch on devices.             #
#                                      #
#   Don't rely on this file being      #
#   present when running at            #
#   Xamarin Test Cloud                 #
#                                      #
########################################

require 'calabash-cucumber/launcher'
require 'rubygems'
require 'zip/zip'

# APP_BUNDLE_PATH = "~/Library/Developer/Xcode/DerivedData/??/Build/Products/Calabash-iphonesimulator/??.app"
# You may uncomment the above to overwrite the APP_BUNDLE_PATH
# However the recommended approach is to let Calabash find the app itself
# or set the environment variable APP_BUNDLE_PATH

Before ('@require_no_photos') do

    simulators_media_contents = Dir.glob(File.join(ENV['HOME'], '/Library/Application Support/iPhone Simulator/*/Media/*'))
    FileUtils.rm_rf(simulators_media_contents)

    @tag_require_no_photos = true
end

After ('@require_no_photos') do
    @tag_require_no_photos = false
end

Before ('@require_photos') do

    simulators_media_folders = Dir.glob(File.join(ENV['HOME'], '/Library/Application Support/iPhone Simulator/*/Media/'))
    simulators_media_contents = Dir.glob(File.join(ENV['HOME'], '/Library/Application Support/iPhone Simulator/*/Media/*'))
    FileUtils.rm_rf(simulators_media_contents)

    Zip::ZipFile.open(File.join(File.dirname(__FILE__), '../../../fixtures/SampleImagesMedia.zip')) do |zip_file|
        zip_file.each do |file|
            simulators_media_folders.each do |destination|
                f_path=File.join(destination, file.name)
                FileUtils.mkdir_p(File.dirname(f_path))
                zip_file.extract(file, f_path) unless File.exist?(f_path)
            end
        end
    end

    @tag_require_photos = true
end

After ('@require_photos') do
    @tag_require_photos = false
end

Before do |scenario|
    @calabash_launcher = Calabash::Cucumber::Launcher.new
    scenario_tags = scenario.source_tag_names
    if scenario_tags.include?('@reset')
        #STDOUT.puts "Resetting simulator for clean state"
        #@calabash_launcher.reset_simulator
        sim_control = RunLoop::SimControl.new
        sim_control.reset_sim_content_and_settings()
    end
    unless @calabash_launcher.calabash_no_launch?
        @calabash_launcher.relaunch
        @calabash_launcher.calabash_notify(self)
    end
end

After do |scenario|
    unless @calabash_launcher.calabash_no_stop?
        calabash_exit
        if @calabash_launcher.active?
            @calabash_launcher.stop
        end
    end
end

at_exit do
  launcher = Calabash::Cucumber::Launcher.new
  if launcher.simulator_target?
    launcher.simulator_launcher.stop unless launcher.calabash_no_stop?
  end
end

#Before do |scenario|
#    scenario_tags = scenario.source_tag_names
#    if get_os_version.to_f < 8.0
#        if scenario_tags.include?('@ios8')
#            puts "Applicable only for ios 8+ versions!"
#            scenario.skip_invoke!
#        end
#    else
#        if scenario_tags.include?('@ios7')
#            puts "Applicable only for ios 7 versions!"
#            scenario.skip_invoke!
#        end
#    end
#end

Around('@ios8') do |scenario, block|
  if get_os_version.to_f < 8.0
    puts "Applicable only for iOS 8 devices!".blue
    scenario.skip_invoke!
  else
    block.call
  end
end

Around('@ios7') do |scenario, block|
  if get_os_version.to_f >= 8.0
    puts "Applicable only for iOS 7 devices!".blue
    scenario.skip_invoke!
  else
    block.call
  end
end