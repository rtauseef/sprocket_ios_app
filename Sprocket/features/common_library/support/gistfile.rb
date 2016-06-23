require 'plist'
require 'colorize'


class SimLocale
  LANG_HASH||={
      "en_US" => {"AppleLanguages" => "en", "AppleLocale" => "en_US"},
      "es_ES" => {"AppleLanguages" => "es", "AppleLocale" => "es_ES"}
    }

  def change_sim_locale(sim_os, sim_name, sim_locale)
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
        sim_path= core_devices+"/"+sim_info["UDID"]
        found=true
        break
      end
    end

    if !found
      puts "ERROR: No compatible simulator found".red
      fail "" 
    end

    #execute plist buddy command
    global_pref_path=sim_path+"/data/Library/Preferences/.GlobalPreferences.plist"
    `echo #{global_pref_path}`

    locale= sim_locale
      abort if LANG_HASH["#{sim_locale}"]==nil # if locale is not specifed stop tests
      
    `/usr/libexec/PlistBuddy #{global_pref_path} -c "Add :AppleLanguages:0 string '#{LANG_HASH["#{locale}"]["AppleLanguages"]}'"`
    `/usr/libexec/PlistBuddy #{global_pref_path} -c "Set :AppleLocale '#{LANG_HASH["#{locale}"]["AppleLocale"]}'"`
$curr_language= `/usr/libexec/PlistBuddy  -c "Print AppleLanguages:0" #{global_pref_path}`
  end
end
