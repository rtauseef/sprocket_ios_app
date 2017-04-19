require 'calabash-cucumber/ibase'

class StickerEditorScreen < Calabash::IBase

    def trait
        title
    end

    def title
        "label marked:'sticker-tool-screen'"
    end
    
    def close
        "UIButton marked:'Discard changes'"
    end

    def save
       "UIButton marked:'Apply changes'" 
    end
    
    def selected_sticker
        "* id:'Fox_TN'"
    end
    

    def navigate
        unless current_page?
            edit_screen = go_to(EditScreen)
            sleep(WAIT_SCREENLOAD)
            wait_for_elements_exist(edit_screen.sticker, :timeout => MAX_TIMEOUT)
            touch edit_screen.sticker
            sleep(WAIT_SCREENLOAD)    
        end
        await
        
    end



end