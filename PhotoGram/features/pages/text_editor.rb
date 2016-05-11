require 'calabash-cucumber/ibase'

class TextEditorScreen < Calabash::IBase

  def trait
    done
  end

  def done
    "button marked:'Done'"
  end

def text_edit(text)
  touch("textView marked:'description'")
  wait_for_keyboard
   text.to_s
  keyboard_enter_text("#{text}")

end
    
def number_of_copies
    query( "label {text CONTAINS 'cop'}", :text)[0].to_i
end

 def text_area
  touch("textView marked:'description'")
 end
    
def printer_name
    query("UIView index:11",:text)[0]
end
    


  def navigate
    unless current_page?
      select_template_screen = go_to(SelectTemplateScreen)
       sleep(STEP_PAUSE)
      if element_exists("view marked:'OverlayView'")
        touch("view marked:'OverlayView'")
        sleep(STEP_PAUSE)
      end
      select_template_screen.text_area
    end
    await

  end

end