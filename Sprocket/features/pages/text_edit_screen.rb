require 'calabash-cucumber/ibase'

class TextEditScreen < Calabash::IBase

    def trait
        title
    end

    def title

        #"label marked:'text-tool-apply-btn'"
        "view marked:'text-tool-apply-btn'"
    end

    def add_text
        #"UIButton marked:'Add text'"
        "* id:'ic_approve_44pt'"
    end
    
    def cancel
        "* id:'ic_cancel_44pt'"
    end
    def save
       "view marked:'text-options-tool-apply-btn'"
    end
    def navigate
        unless current_page?
            edit_screen = go_to(EditScreen)
            sleep(WAIT_SCREENLOAD)
            scroll "UICollectionView",:right
            sleep(STEP_PAUSE)
           # wait_for_elements_exist(edit_screen.text, :timeout => MAX_TIMEOUT)
            #touch edit_screen.text
            touch "IMGLYIconCaptionCollectionViewCell * id:'editText'"
            sleep(WAIT_SCREENLOAD)    
        end
        await
                
    end



end