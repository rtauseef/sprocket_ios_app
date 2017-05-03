require 'calabash-cucumber/ibase'

class EditScreen < Calabash::IBase

    def trait
        title
    end

    def title
        "label marked:'editor-tool-screen'"
    end
    
    def crop
        "IMGLYIconCaptionCollectionViewCell * id:'editCrop'"
    end
    
    def text
        "IMGLYIconCaptionCollectionViewCell * id:'editText'"
    end
    
    def filter
        "IMGLYIconCaptionCollectionViewCell * id:'editFilters'"
    end
    
    def frame
        "IMGLYIconCaptionCollectionViewCell * id:'editFrame'"
    end
    
    def sticker
        "IMGLYIconCaptionCollectionViewCell * id:'editSticker'"
    end
    
    def magic
        "IMGLYIconCaptionCollectionViewCell * id:'editMagic'"
    end
    
    def check
        "UIButton marked:'editor-tool-apply-btn'"
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
       
    def selected_frame
        "* id:'1_turquoise_frame'" 
    end

    def undo
        "* id:'ic_undo_24pt'"
    end

    def navigate
        unless current_page?
            preview_screen = go_to(FlickrPreviewScreen)
            sleep(WAIT_SCREENLOAD)
            #wait_for_elements_exist(preview_screen.edit, :timeout => MAX_TIMEOUT)
            touch query("view marked:'Edit")
            sleep(WAIT_SCREENLOAD)    
            if element_exists("view marked:'Authorize' index:0")
                touch("view marked:'Authorize' index:0")
            end
           
        if get_xcode_version.to_i < 8
            if element_exists(uia_query :view, marked:'OK')
                uia_tap_mark("OK")
            end
        else
            authorize_msg = device_agent.query({marked:"OK"})
            if authorize_msg.length >0
                device_agent.touch({marked:"OK"})
            end
        end
        end
        await
         #$curr_edit_img_frame_width = query("UIImageView index:0").first["frame"]["width"]
        $curr_edit_img_frame_width = query("GLKView").first["frame"]["width"]
        #$curr_edit_img_frame_height = query("UIImageView index:0").first["frame"]["height"]
        $curr_edit_img_frame_height = query("GLKView").first["frame"]["height"]
        
    end



end