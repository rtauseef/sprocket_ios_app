require 'calabash-cucumber/ibase'

class FrameEditorScreen < Calabash::IBase

    def trait
        title
    end

    def title
        "label marked:'frame-tool-screen'"
    end
    
    def close
        "UIButton marked:'Discard changes'"
    end

    def save
       "UIButton marked:'frame-tool-apply-btn'"
    end
    
    def navigate
        unless current_page?
            edit_screen = go_to(EditScreen)
            sleep(WAIT_SCREENLOAD)
            #wait_for_elements_exist(edit_screen.frame, :timeout => MAX_TIMEOUT)
            #touch edit_screen.frame
            touch "IMGLYIconCaptionCollectionViewCell * id:'editFrame'"
            sleep(WAIT_SCREENLOAD)    
        end
        await
        
    end



end