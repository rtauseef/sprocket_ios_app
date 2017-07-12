require 'calabash-cucumber/ibase'

class BrushEditorScreen < Calabash::IBase

    def trait
        title
    end

    def title
        "label marked:'brush-tool-screen'"
    end

    def save
       "UIButton marked:'brush-tool-apply-btn'"
    end
    def cancel
        "view marked:'Discard changes'" 
    end
   
    def color_apply
        "all view marked:'brush-color-tool-apply-btn'"
    end
    def size_slider
        slider_val= Random.rand(5...85)
        return slider_val
    end
    def hardness_slider
        slider_val= Random.rand(0.1...1.0)
        return slider_val
    end
    def color_button
        "view marked:'Color'"
    end
    def size_button
        "view marked:'Size'"
    end
    def hardness_button
         "view marked:'Hardness'"

    end
    def bring_to_front_button
        "view marked:'Bring to front'"
    end
    def delete_button
        "view marked:'Delete'"
    end
    def navigate
        unless current_page?
            edit_screen = go_to(EditScreen)
            sleep(WAIT_SCREENLOAD)
            scroll "UICollectionView",:right
            touch edit_screen.brush
            sleep(WAIT_SCREENLOAD)    
        end
        await
                
    end



end