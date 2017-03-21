require 'plist'
require 'colorize'


class SimLocale
  LANG_HASH||={
      "en_US" => {"AppleLanguages" => "en", "AppleLocale" => "en_US"},
      "es_ES" => {"AppleLanguages" => "es", "AppleLocale" => "es_ES"},
      "fr_FR" => {"AppleLanguages" => "fr", "AppleLocale" => "fr_FR"},
      "de_DE" => {"AppleLanguages" => "de", "AppleLocale" => "de_DE"},
      "it_IT" => {"AppleLanguages" => "it", "AppleLocale" => "it_IT"},
      "nl_NL" => {"AppleLanguages" => "nl", "AppleLocale" => "nl_NL"},
      "zh_Hans" => {"AppleLanguages" => "zh", "AppleLocale" => "zh_Hans"},
      "pt_PT" => {"AppleLanguages" => "pt", "AppleLocale" => "pt_PT"},
      "sv_SE" => {"AppleLanguages" => "sv", "AppleLocale" => "sv_SE"},
      "da_DK" => {"AppleLanguages" => "da", "AppleLocale" => "da_DK"},
      "fi_FI" => {"AppleLanguages" => "fi", "AppleLocale" => "fi_FI"},
      "et_EE" => {"AppleLanguages" => "et", "AppleLocale" => "et_EE"},
      "lv_LV" => {"AppleLanguages" => "lv", "AppleLocale" => "lv_LV"},
      "lt_LT" => {"AppleLanguages" => "lt", "AppleLocale" => "lt_LT"},
      "nb_NO" => {"AppleLanguages" => "nb", "AppleLocale" => "nb_NO"},
      "el_GR" => {"AppleLanguages" => "el", "AppleLocale" => "el_GR"},
      "id_ID" => {"AppleLanguages" => "id", "AppleLocale" => "id_ID"},
      "pt_BR" => {"AppleLanguages" => "pt", "AppleLocale" => "pt_BR"},
      "ru_RU" => {"AppleLanguages" => "ru", "AppleLocale" => "ru_RU"},
      "th_TH" => {"AppleLanguages" => "th", "AppleLocale" => "th_TH"},
      "tr_TR" => {"AppleLanguages" => "tr", "AppleLocale" => "tr_TR"}
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
