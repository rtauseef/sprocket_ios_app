require 'calabash-cucumber/ibase'
require_relative '../common/base_html_screen'

class InstagramScreen < Calabash::IBase

  def trait
    instagram_logo
  end

  def instagram_logo
    "imageView marked:'InstagramLogo.png'"
  end


 def instagram_screen
    "window"
  end

  def navigate
    sleep(STEP_PAUSE)
    await
  end

end
