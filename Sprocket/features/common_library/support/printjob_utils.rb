
require "net/http"
require "uri"
require "json"

def req_handler url
    info = get_config_data
    dev_info = info['devices']
    uri = URI.parse("http://"+dev_info['ip'] +":"+dev_info['port']+"/"+url)
    request =Net::HTTP::Post.new(uri.request_uri)
    http = Net::HTTP.new(uri.host, uri.port)
    response = http.request(request)
    return JSON.parse(response.body)
end

def get_printjob_attr
   jobs = req_handler 'getAttributes'
   return JSON.parse(jobs.to_json)
end

def confirm_print
   confirm = req_handler 'printConfirm'
   return JSON.parse(confirm.to_json)
end

def run_tshark
   run = req_handler 'runTshark'
   return JSON.parse(run.to_json)
end 

def stop_tshark
  sleep(10)
  run = req_handler 'stopTshark'
  return JSON.parse(run.to_json)
end


def get_config_data
    config = File.read(File.dirname(__FILE__)+"//config.json")
    data = JSON.parse(config)
    return data
end
