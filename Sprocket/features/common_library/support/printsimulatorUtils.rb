require 'json'
require "net/http"
require "uri"
require 'FileUtils'
require 'rubygems'
require 'ax_elements'

# Highlight objects that the mouse will move to
Accessibility.debug = true
$finder
def get_metrics
  result = `curl "http://hpmobileprint:print1t@print-metrics-test.twosmiles.com/api/v1/mobile_app_metrics"`
  #result = `curl -x http://proxy.atlanta.hp.com:8080 -L "http://hpmobileprint:print1t@print-metrics-test.twosmiles.com/api/v1/mobile_app_metrics"`
  result = JSON[result]
  return JSON[result[result.length-1]]
end

def start_print_simulator
  #puts ENV['HOME']+'/Applications'
  #Dir.chdir ENV['HOME']+'/Applications'
  Dir.chdir '/Applications'
  %x[open -a Printer\\ Simulator.app]
end

def remove_files
  Dir.chdir __dir__
  json = File.read('config.json')
  getdata = JSON.parse(json)
  print_path = getdata["printpath"]
  print_path = ENV['HOME'] + print_path + '*'
  foldercontents = FileUtils.rm_rf(Dir.glob(print_path))
  return foldercontents
end

def gettemplate
   $pdfname = $prev_temp 
   if $paper_size == "8.5x11"
     $paper_size = "8_5x11" + "_" + $paper_type
   end
   simulator = get_simulatorversion 
   $pdfname = $pdfname + "_" + $paper_size + "_" +"BW_OFF_" +simulator +".pdf"
   Dir.chdir __dir__
   json = File.read('config.json')
   getdata = JSON.parse(json)
   path = File.dirname(__FILE__)
   path = path = File.expand_path("..",path)
   $templatepath = path + "/image_template/"    
   $templatepath = $templatepath + $pdfname
   return $templatepath
end

def comparepdf
  kill_printer_simulator = `osascript -e 'quit app "Printer Simulator"'`
  filegenerated = getfile
  filegeneratedDir = File.dirname(filegenerated)
    
  val = `compare -metric RMSE  #{$templatepath} #{filegenerated} NULL: 2>#{filegeneratedDir}/diff.txt`
  diffFilePath = filegeneratedDir + '/diff.txt'
  contents = File.read(diffFilePath)
  return contents
end

def getfile
  Dir.chdir __dir__
  json = File.read('config.json')
  getdata = JSON.parse(json)
  print_path = getdata["printpath"]
  print_path = ENV['HOME'] + print_path + '*'
  filearray = Dir[print_path]
  return filearray[0]
end

def open_print_simulator
    remove_files
  $finder = app_with_bundle_identifier 'com.apple.PrinterSimulator'
  sleep 3
  set_focus_to $finder
end

def click_load_paper
  sleep 3 
  click $finder.Window.Button(title: 'Load Paper') 
end

def click_paper_size_sensors (printer_name)
  sleep 3
  getClickPosition = $finder.Window.Sheet.StaticText(value: printer_name).Position
  
  point = [getClickPosition.x + 1, getClickPosition.y + 23]
  move_mouse_to point
  Mouse.click point
  sleep 2
  click $finder.Window.Sheet.Button(title: 'OK')
end

def gethostname
    pcname = `scutil --get ComputerName`
    pcname = pcname.rstrip
    return pcname
end

def clear_printersimulatorlog
  sleep 3 
  click $finder.Window.Button(title: 'Clear Log') 
end

def save_printersimulatorlog
    if (File.exists?(ENV['HOME']+"/PrinterSimulator.log"))
  File.delete(ENV['HOME']+"/PrinterSimulator.log")
    end
  $finder = app_with_bundle_identifier 'com.apple.PrinterSimulator'
  sleep 3
  set_focus_to $finder
  sleep 3 
  click $finder.menu_bar_item(title: 'Simulation')
  sleep 3 
  click $finder.menu_item(title: 'Save Log...')
  saveloc =  ENV['HOME'] + '/PrinterSimulator.log'

    
  $finder.Window.Sheet.TextField(value: 'PrinterSimulator.log').set :value,"/"
  $finder.Window.Sheet.TextField(value: '/').set :value,saveloc
  click $finder.Window.Button(title: 'Go')
  click $finder.Window.Button(title: 'Save Log')
  sleep 2
end

def check_paper_size(printer_name)
  sleep 3
   getClickPosition = $finder.Window.Sheet.StaticText(value: printer_name).Position
  checkpoint = CGPoint.new(getClickPosition.x + 1,getClickPosition.y + 23)
  val = $finder.Window.Sheet.CheckBox(position: checkpoint).value
  if (val == 0 )
    click $finder.Window.Sheet.CheckBox(position: checkpoint)
 end
    sleep 2
  click $finder.Window.Sheet.Button(title: 'OK')
end

def uncheck_paper_size(printer_name)
  sleep 3
  getClickPosition = $finder.Window.Sheet.StaticText(value: printer_name).Position
  checkpoint = CGPoint.new(getClickPosition.x + 1,getClickPosition.y + 23)
  val = $finder.Window.Sheet.CheckBox(position: checkpoint).value
  if (val == 1 )
    click $finder.Window.Sheet.CheckBox(position: checkpoint)
 end
    sleep 2
  click $finder.Window.Sheet.Button(title: 'OK')
end

def get_logvalues
 hash = {"paper_size"=>"", "paper_type"=>""}
 logpath = ENV['HOME']
 logpath = logpath + "/PrinterSimulator.log"
 f =File.open(logpath , "r")
 f.each_line{|line|
 if (line.match("header.printQuality")!= nil||line.match("header.width")!= nil||line.match("header.height")!= nil||line.match("header.resolution")!= nil)
     if line.match("printQuality")
     line = line.split('=')[-1]
     if line.match("4")
         hash["paper_type"] = "Plain Paper"
      
     else
         hash["paper_type"] = "Photo Paper"
        
     end
        end
    if line.match("width")
    width = line.split('=')[-1]
        width = width.strip
        hash["paper_size-x"] = width
    end
    if line.match("height")
    height = line.split('=')[-1]
        height = height.strip
        hash["paper_size-y"] = height
     end
    if line.match("resolution")
    resolution = line.split('=')[-1]
        resolution = resolution.strip
        hash["resolution"] = resolution
    end
end
}
f.close
    return hash
end

def get_simulatorversion
  getDevTarg = ENV['DEVICE_TARGET'].gsub('(','')
  splitdevTarg = getDevTarg.split(" ") 
  os_version = splitdevTarg[0] +splitdevTarg[1] + splitdevTarg[2]
  os_version = os_version.gsub(".","_")
  return os_version
end

def get_configvalue ( size  , values)
Dir.chdir __dir__
json = File.read('config.json')
getdata = JSON.parse(json)
getcoord = size + "-" +values
val = getdata["simulatorpapersize"][getcoord]
return val
end

def gethost
hostname = ENV['hostname']
hostname
end

def fetch_Xcodelog
  deviceId = getsimulatorId
  $logpath = ENV['HOME'] + "/Library/Developer/CoreSimulator/Devices/"
  $logpath = $logpath + deviceId
  getlogfile
end

def getsimulatorId
 value = %x[instruments -s devices]
 getDevTarg = ENV['DEVICE_TARGET']
 value.each_line do |line|
  if line.include? getDevTarg
    line = line.split(getDevTarg)
    line[1] = line[1].split("]")[0]
    line[1] = line[1].split("[")[-1]
    return line[1]
  end
 end
end

def getlogfile
  getAppName = ENV['APP_BUNDLE_PATH']
  appname = File.basename(getAppName , ".app")
  Dir.chdir $logpath
  str = %q["*.log"]
  searchstr = "find . -name #{str}"
  value = %x[ #{searchstr} ]
  value.each_line do |line|
  logname = File.basename(line)
  if (logname.index(".archived.log") == nil && logname.match(appname))
    line.slice!(".")
    $logpath = $logpath + line
    $logpath = $logpath.rstrip
   end
 end
end

def checkhomepage
  val = "false"
  f =File.open($logpath , "r")
  f.each_line{|line|
  if (line.match("loaded")!= nil)
    val = "true"
    break
  end
  }
  f.close
  val
end

def checktemplate(template)
  val = "false"
  f =File.open($logpath , "r")
  f.each_line{|line|
  if (line.match("Label:\"#{template}\"")!= nil)
    val = "true"
    break
  end
  }
  f.close
  val
end

def checkcameraroll
  sleep(3.0)
  val = "false"
  f =File.open($logpath , "r")
  f.each_line{|line|
  if (line.match("Action:\"MCSaveToCameraRollActivity\"") || line.match("Action:\"PGSaveToCameraRollActivity\"")!= nil)
    val = "true"
    break
  end
  }
  f.close
  val
end

def checkprint(paper_size)
  val = "false"
  f =File.open($logpath , "r")
  f.each_line{|line|
      if (line.match("Action:\"PrintFromShare\", Label:\"#{paper_size} Photo Paper")!= nil)
    val = "true"
    break
  end
  }
  f.close
  val
end

def checktype(paper_type)
  val = "false"
  f =File.open($logpath , "r")
  f.each_line{|line|     
      if (line.match("Action:\"PrintFromShare\", Label:\"8.5 x 11 #{paper_type}\"")!= nil)
    val = "true"
    break
  end
  }
  f.close
  val
end

def cancelprint
  val = "false"
  f =File.open($logpath , "r")
  f.each_line{|line|
  if line.match("Label:\"Cancel\"")
    val = "true"
    break
  end
  }
  f.close
  val
end
