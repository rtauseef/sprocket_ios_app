require 'calabash-cucumber/ibase'

class StickerOptionEditorScreen < Calabash::IBase

    def trait
        title
    end

    def title
        "label marked:'sticker-options-tool-screen'"
    end
    
    def close
        "UIButton marked:'Discard changes'"
    end

    def save
      "UIButton marked:'sticker-options-tool-apply-btn'"
    end
    def delete
        "view marked:'Delete'"
    end
    def undo
        "* id:'ic_undo_24pt'"
    end
    def redo
        "* id:'ic_redo_24pt'"
    end

    
    def navigate
        unless current_page?
            edit_screen = go_to(StickerEditorScreen)
            sleep(WAIT_SCREENLOAD)
            wait_for_elements_exist(edit_screen.sticker, :timeout => MAX_TIMEOUT)
            touch edit_screen.sticker
            sleep(WAIT_SCREENLOAD)    
        end
        await
        
    end



end