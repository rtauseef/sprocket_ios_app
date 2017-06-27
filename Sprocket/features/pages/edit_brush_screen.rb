require 'calabash-cucumber/ibase'

class BrushEditorScreen < Calabash::IBase

    def trait
        title
    end

    def title
        "label marked:'brush-tool-screen'"
    end
    
    def close
        "UIButton marked:'Discard changes'"
    end

    def save
       "UIButton marked:'brush-tool-apply-btn'"
    end
    def bring_to_front
        "all view marked:'Bring to front'"
    end
    def hardness
        "all view marked:'Hardness'"
    end
    def size
        "all view marked:'Size'"
    end
    def color
        "all view marked:'Color'"
    end
    def delete
        "all view marked:'Delete'"
    end
    def color_apply
        "all view marked:'brush-color-tool-apply-btn'"
    end
    def size_slider
        slider_val= Random.rand(5...90)
        return slider_val
    end
    def hardness_slider
        slider_val= Random.rand(0.1...1.0)
        return slider_val
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