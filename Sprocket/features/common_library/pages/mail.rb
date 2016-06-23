require 'calabash-cucumber/ibase'
require_relative '../../pages/share'

class MailScreen < Calabash::IBase

  def trait
    #New_message
  end

  def New_message
    #"label marked:'New Message'"
      uia_query :view, marked:'My HP Snapshot'
  end


  def navigate
    unless current_page?
      share_screen = go_to(ShareScreen)
      touch share_screen.mail
    end
    await
  end



end