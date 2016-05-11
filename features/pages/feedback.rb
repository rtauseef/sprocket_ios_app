

require 'calabash-cucumber/ibase'

class FeedbackScreen < Calabash::IBase

  def trait
    feedback
  end

  def feedback
     "view {text BEGINSWITH 'Feedback on HP Social Media Snapshots'}"
  end



  def navigate
    unless current_page?
      home_screen = go_to(HomeScreen)
      touch home_screen.hamburger
      pause
      touch home_screen.send_feedback
    end
    await
  end



end