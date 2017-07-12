require 'calabash-cucumber/ibase'

class StickerOptionEditorScreen < Calabash::IBase

    def trait
        title
    end

    def title
        "label marked:'sticker-options-tool-screen'"
    end
    
    def save
      "UIButton marked:'sticker-options-tool-apply-btn'"
    end
    def delete
        "view marked:'Delete'"
    end
=begin
    def undo
        "* id:'ic_undo_24pt'"
    end
    def redo
        "* id:'ic_redo_24pt'"
    end
=end
    def cancel
        "view marked:'Discard changes'" 
    end
    
    def navigate
        unless current_page?
            edit_screen = go_to(StickerEditorScreen)
            sleep(WAIT_SCREENLOAD)
            #wait_for_elements_exist(edit_screen.sticker, :timeout => MAX_TIMEOUT)
            #touch edit_screen.sticker
            sticker_name=$sticker["Summer Category"]["sticker_0"]['name']
            select_sticker sticker_name
            sleep(WAIT_SCREENLOAD)    
        end
        await
        
    end



end