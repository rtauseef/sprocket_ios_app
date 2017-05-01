require 'calabash-cucumber/ibase'

class TextOptionEditorScreen < Calabash::IBase

    def trait
        title
    end

    def title
        "label marked:'text-options-tool-screen'"
    end
    
    def close
        "UIButton marked:'Discard changes'"
    end

    def save
        "* id:'ic_approve_44pt'"
    end
    
    def delete
        "view marked:'Delete'"
    end
    
    def navigate
        unless current_page?
            edit_screen = go_to(TextEditScreen)
            sleep(WAIT_SCREENLOAD)
            if element_exists ("textView")
                touch("textView")
                clear_text("textView")
            end
            sleep(WAIT_SCREENLOAD)
            $template_text ="TestAutomation"+(Time.now.inspect.split.join).to_s
            keyboard_enter_text $template_text
            sleep(STEP_PAUSE)
            touch edit_screen.add_text
            # wait_for_elements_exist(edit_screen.sticker, :timeout => MAX_TIMEOUT)
            # touch edit_screen.sticker
            sleep(WAIT_SCREENLOAD)    
        end
        await
        
    end



end