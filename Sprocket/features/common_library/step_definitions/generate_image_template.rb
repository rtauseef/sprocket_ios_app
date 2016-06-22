require 'FileUtils'

And (/^I generate template file$/) do
  templatepath = gettemplate
  templateName = File.basename(templatepath)
  templateDir = File.dirname(templatepath)
    
  generatedfilepath = getfile
  generatedFileDir = File.dirname(generatedfilepath)
    
  File.rename(generatedfilepath, generatedFileDir + "/" + templateName)
  FileUtils.cp (generatedFileDir + "/" + templateName), templateDir
end