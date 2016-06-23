Then(/^I touch the "(.*?)" input button$/) do |button_text|

  query("webView", :stringByEvaluatingJavaScriptFromString => 'document.getElementsByTagName("iframe")[0].contentWindow.document.getElementsByName("#{button_text}")[0].click()')

  sleep(STEP_PAUSE)
end
