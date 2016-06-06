require 'calabash-cucumber/ibase'
require_relative '../common/base_html_screen'

class FlickrScreen < Calabash::IBase

  def trait
    flickr_logo
  end

  def flickr_logo
    "imageView marked:'FlickrLogo.png'"
  end


 def flickr_screen
    "window"
  end

  def navigate
    sleep(STEP_PAUSE)
    xcoord = query("pageControl child view index:3").first["rect"]["x"]
    ycenter = query("pageControl child view index:3").first["rect"]["center_y"]
    touch(nil, :offset => {:x => xcoord-5.to_i, :y => ycenter.to_i})
    sleep(STEP_PAUSE)
    xcoord = query("pageControl child view index:3").first["rect"]["x"]
    ycenter = query("pageControl child view index:3").first["rect"]["center_y"]
    touch(nil, :offset => {:x => xcoord-5.to_i, :y => ycenter.to_i})
    sleep(STEP_PAUSE)
    await
  end

end












