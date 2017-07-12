require 'calabash-cucumber/ibase'

class FilterEditorScreen < Calabash::IBase

    def trait
        title
    end

    def title
        "label marked:'filter-tool-screen'"
    end
    def save
       "UIButton marked:'filter-tool-apply-btn'"
    end
    def cancel
        "view marked:'Discard changes'" 
    end
    def navigate
        unless current_page?
            edit_screen = go_to(EditScreen)
            sleep(WAIT_SCREENLOAD)
            #wait_for_elements_exist(edit_screen.filter, :timeout => MAX_TIMEOUT)
            #touch edit_screen.filter
            touch "IMGLYIconCaptionCollectionViewCell * id:'editFilters'"
            sleep(WAIT_SCREENLOAD)    
        end
        await
                
    end



end