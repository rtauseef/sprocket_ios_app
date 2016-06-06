require 'calabash-cucumber/ibase'

class AboutScreen < Calabash::IBase

  def trait
    about
  end

  def about
    "view marked:'About'"
  end

def build_version
    query("UILabel index:3",:text)[0]
end

  def navigate
    unless current_page?
      home_screen = go_to(HomeScreen)
      touch home_screen.hamburger
      pause
      touch home_screen.About
    end
    await
  end



end