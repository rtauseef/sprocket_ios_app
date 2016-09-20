require 'calabash-cucumber/ibase'

class SelectTemplateScreen < Calabash::IBase

 $prev_temp="Kerouac"
  def trait
    select_template
  end

  def select_template
    "navigationBar marked:'Select Template'"
  end

  def share_icon
    "view marked:'Share.png'"
  end

  def template_applied
  query("view marked:'Photo View'").first["frame"]["width"]
  end

  def text_area
    touch("textView marked:'description'")
  end
     def print_queue
        "view marked:'Print Queue'"
        end
    def selected_template
  query("collectionView marked:'TemplateCollectionView'",:accessibilityValue).first
  end
    
    def user_name
        query("* id:'username'",:text)[0]
    end
    
    def photo_location
        query("view marked:'location'",:text)[0]
    end
        

  def navigate
    unless current_page?
      select_photo_screen = go_to(HomeScreen)
      sleep(WAIT_SCREENLOAD)
      end
      sleep(STEP_PAUSE)
      #touch select_photo_screen.second_photo
      touch query("collectionViewCell index:1")
    await
    end
  end

  

