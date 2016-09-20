require 'calabash-cucumber/ibase'

class FrameEditorScreen < Calabash::IBase

    def trait
        title
    end

    def title
        "label marked:'FRAME'"
    end
    
    def close
        "UIButton marked:'Discard changes'"
    end

    def save
       "UIButton marked:'Apply changes'" 
    end
    
    def selected_frame
        "* id:'1_turquoise_frame'" 
    end

    def navigate
        unless current_page?
            edit_screen = go_to(EditScreen)
            sleep(WAIT_SCREENLOAD)
            wait_for_elements_exist(edit_screen.frame, :timeout => MAX_TIMEOUT)
            touch edit_screen.frame
            sleep(WAIT_SCREENLOAD)    
        end
        await
        
    end



end