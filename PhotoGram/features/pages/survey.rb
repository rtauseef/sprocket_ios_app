require 'calabash-cucumber/ibase'

class SurveyScreen < Calabash::IBase

  def trait
    survey
  end

  def survey
    #"view marked:''"
      "UIWebView css:'H1' {textContent CONTAINS 'HP Social Media Snapshots'}"
  end



  def navigate
    unless current_page?
      home_screen = go_to(HomeScreen)
      touch home_screen.hamburger
      pause
      touch home_screen.take_survey
    end
    await
  end



end