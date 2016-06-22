# My appium utils function
require 'selenium-webdriver'

def server_url
  'http://localhost:4723/wd/hub'
end
 
def web_capabilities
      data =  version_devnam_info
            {  
                'platformName' => 'iOS',
                'platformVersion' => data["version"],
                'browserName' => 'Safari',
                'autoAcceptAlerts' => true,
                'deviceName' => data["devicename"].strip
            }
end
 

def selenium
  @driver ||= Selenium::WebDriver.for(:remote, :desired_capabilities => web_capabilities, :url => server_url)
end


def version_devnam_info
    info = ARGV[1]  
    info  = info.split("=")   
    device = info[1].split("(")
    version =device[1].split(" ")
    if get_xcode_version.to_i < 6.3
        device_name = device[0]
    else
        device_name = info[1].strip + " ["+ get_udid + "]"
    end
    details = {"version" => version[0], "devicename" => device_name}
    
    return details
end
