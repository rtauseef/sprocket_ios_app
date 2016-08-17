require 'calabash-cucumber/ibase'

class EditScreen < Calabash::IBase

    def trait
        title
    end

    def title
        "UILabel text:'EDITOR'"
    end
    
    def crop
        "UIImageView * id:'editCrop'"
    end
    
    def text
        "UIImageView * id:'editText'"
    end
    
    def filter
        "UIImageView * id:'editFilters'"
    end
    
    def frame
        "UIImageView * id:'editFrame'"
    end
    
    def sticker
        "UIImageView * id:'editSticker'"
    end
    
    def check
        "UIButton marked:'Save photo'"
    end
    
    def close
        "UIButton marked:'Discard photo'"
    end
    
    def modal_title
       "UILabel text:'Alert'" 
    end
    
    def modal_content
      "label {text CONTAINS 'Do you want to return to preview and dismiss your edits?'}" 
    end
    
    def yes
        "UILabel text:'Yes'"
    end
    
    def no
        "UILabel text:'No'"
    end
    
    def save
       "UIButton marked:'Apply changes'" 
    end
    
    def add_text
        "UIButton marked:'Add text'"
    end
    
    def selected_sticker
        "IMGLYStickerImageView"
    end
    
    def selected_frame
        "* id:'blue_frame'" 
    end

    

    def navigate
        unless current_page?
            preview_screen = go_to(PreviewScreen)
            sleep(WAIT_SCREENLOAD)
            wait_for_elements_exist(preview_screen.edit, :timeout => MAX_TIMEOUT)
            touch preview_screen.edit
            sleep(WAIT_SCREENLOAD)    
        end
        await
         $curr_edit_img_frame_width = query("UIImageView index:0").first["frame"]["width"]
        $curr_edit_img_frame_height = query("UIImageView index:0").first["frame"]["height"]
        
    end



end