require 'calabash-cucumber/ibase'

class SurveyScreen < Calabash::IBase

  def trait
    survey_title
  end

  def survey_title
    #"view marked:''"
      "view {text CONTAINS 'HP Sprocket'}"
  end
  def done
    "view marked:'Done'"
  end


  def navigate
    unless current_page?
      landing_screen = go_to(LandingScreen)
      touch landing_screen.hamburger_logo
      sleep(STEP_PAUSE)
      touch landing_screen.take_survey
    end
    await
  end

end