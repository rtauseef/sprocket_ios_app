require 'calabash-cucumber/ibase'

class TextEditScreen < Calabash::IBase

    def trait
        title
    end

    def title
        "label marked:'Add text'"
    end
    

    def add_text
        "UIButton marked:'Add text'"
    end
    
    def cancel
        "UIButton marked:'Cancel'"
    end
    
    def navigate
        unless current_page?
            edit_screen = go_to(EditScreen)
            sleep(WAIT_SCREENLOAD)
            wait_for_elements_exist(edit_screen.text, :timeout => MAX_TIMEOUT)
            touch edit_screen.text
            sleep(WAIT_SCREENLOAD)    
        end
        await
                
    end



end