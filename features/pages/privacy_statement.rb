require 'calabash-cucumber/ibase'

class PrivacyStatementScreen < Calabash::IBase

  def trait
    statement
  end

  def statement
    #"view marked:''"
      "UIWebView css:'H1' {textContent CONTAINS 'HP Inc. Privacy Statement'}"
  end



  def navigate
    unless current_page?
      home_screen = go_to(HomeScreen)
      touch home_screen.hamburger
      pause
      touch home_screen.privacy_statement
    end
    await
  end



end