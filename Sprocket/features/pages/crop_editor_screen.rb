require 'calabash-cucumber/ibase'

class CropEditorScreen < Calabash::IBase

    def trait
        title
    end

    def title
        "label marked:'transform-tool-screen'"
    end
   
    def save
       "UIButton marked:'transform-tool-apply-btn'"
    end
    
    #def selected_frame
     #   "* id:'blue_frame'" 
    #end

    def cancel
        "view marked:'Discard changes'" 
    end
    def two_to_three
        "view marked:'2:3'"
    end
     def three_to_two
        "view marked:'3:2'"
    end
    def rotate
        "view marked:'ic rotateLeft 48pt'"
    end
    def flip_horizontal
        "view marked:'ic rotateLeft 48pt'"
    end

    def navigate
        unless current_page?
            edit_screen = go_to(EditScreen)
            sleep(WAIT_SCREENLOAD)
            scroll "UICollectionView",:right
            scroll "UICollectionView",:right
            sleep(STEP_PAUSE)
            #wait_for_elements_exist(edit_screen.crop, :timeout => MAX_TIMEOUT)
            #touch edit_screen.crop
            touch "IMGLYIconCaptionCollectionViewCell * id:'editCrop'"
            sleep(WAIT_SCREENLOAD)    
        end
        await
                
    end



end

