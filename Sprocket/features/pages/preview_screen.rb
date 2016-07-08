require 'calabash-cucumber/ibase'

class PreviewScreen < Calabash::IBase

  def trait
    camera
  end

  def camera
    "view marked:'previewCamera'"
  end

  def cancel 
    "view marked:'previewX'"
  end
  def edit
    "view marked:'previewEdit'"
  end
 def print
    "view marked:'previewPrinter'"
  end
    def share
    "view marked:'previewShare'"
  end
  
  def navigate
    unless current_page?
      select_photo_screen = go_to(HomeScreen)
      sleep(WAIT_SCREENLOAD)
      end
      sleep(STEP_PAUSE)
      touch query("collectionViewCell index:1")
    await
    end
  end

  

