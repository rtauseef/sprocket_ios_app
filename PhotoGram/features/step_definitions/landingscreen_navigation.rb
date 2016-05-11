Given(/^I am on the instagram login screen$/) do
res = query("imageView marked:'Instagram'")
end

Then /^I touch the next page control$/ do
  xcoord = query("pageControl child view index:3").first["rect"]["x"]
  ycenter = query("pageControl child view index:3").first["rect"]["center_y"]
  touch(nil, :offset => {:x => xcoord-5.to_i, :y => ycenter.to_i})
  end
 
Then /^I should navigate to facebook screen$/ do
    
res = query("imageView marked:'Facebook'")
 end

Then /^I should navigate to Flickr photos screen$/ do
res1 = query("imageView marked:'Flickr'")
end

Then /^I should navigate to Social Media Snapshots screen$/ do
res2 = query("view marked:'CameraRoll'")
 end

Then /^I touch the previous page control$/ do
  xcoord = query("pageControl child view index:2").first["rect"]["x"]
  ycenter = query("pageControl child view index:2").first["rect"]["center_y"]
  touch(nil, :offset => {:x => xcoord-5.to_i, :y => ycenter.to_i})
end

Then /^I should navigate to print queue screen$/ do
res3 = query("view marked:'Print Queue'")
end