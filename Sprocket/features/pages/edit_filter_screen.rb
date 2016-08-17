require 'calabash-cucumber/ibase'

class FilterEditorScreen < Calabash::IBase

    def trait
        title
    end

    def title
        "label marked:'FILTER'"
    end
    
    
    def close
        "UIButton marked:'Discard changes'"
    end

    def filter_1
        "view marked:'Candy'"
    end
    def save
       "UIButton marked:'Apply changes'" 
    end
    def navigate
        unless current_page?
            edit_screen = go_to(EditScreen)
            sleep(WAIT_SCREENLOAD)
            wait_for_elements_exist(edit_screen.filter, :timeout => MAX_TIMEOUT)
            touch edit_screen.filter
            sleep(WAIT_SCREENLOAD)    
        end
        await
                
    end



end