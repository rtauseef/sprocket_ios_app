require 'calabash-cucumber/ibase'
require_relative '../common/base_html_screen'

class SideMenuScreen < Calabash::IBase

  def trait
    cameraroll_logo
  end

  def cameraroll_logo
    "view marked:'LoginCameraRoll.png'"
  end


def cameraroll_button
    "button marked:'Camera Roll'"
  end
    
 def instagram_screen
    "window"
  end

 def navigate
   
     sleep(2.0)
      touch cameraroll_logo
      sleep(2.0)
     swipe_coach_marks_view
=begin
      if element_exists("PGSwipeCoachMarksView")
      sleep(1.0)
      a = send_uia_command :command => "target.rect().size.width"
      send_uia_command :command => "target.dragFromToForDuration({x:50.00, y:200.00}, {x:(#{a['value']}*0.9), y:200.00}, 1)"
      sleep(1.0)
=end
      touch cameraroll_button
      sleep(1.0)
    touch("view marked:'Authorize' index:0")
    sleep(5.0)
      touch "HPPRSelectAlbumTableViewCell"
      sleep(2.0)
      touch "UIImageView index:4"
      sleep(2.0)
      touch("view marked:'Share.png'")
      sleep(2.0)
      touch "view marked:'Print Queue'"
      sleep(5.0)
      touch "view marked:'Add to Print Queue'"
      sleep(2.0)
      touch "view marked:'Done'"
      sleep(2.0)
      touch("view marked:'Back'")
      sleep(2.0)
      touch("view marked:'HPPRBack.png'")
      sleep(5.0)
      touch("view marked:'Hamburger'")
      sleep(2.0)
    end
  end
