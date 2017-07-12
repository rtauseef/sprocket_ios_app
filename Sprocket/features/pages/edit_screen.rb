require 'calabash-cucumber/ibase'

class EditScreen < Calabash::IBase

    def trait
        title
    end

    def title
        "label marked:'editor-tool-screen'"
    end
    def autofix
        "view marked:'Magic'"
    end
    def adjustment
        "view marked:'Adjust'"
    end
    def filter
        "view marked:'Filter"
    end
    def frame
        "view marked:'Frame"
    end
    def sticker
        "view marked:'Sticker"
    end
    def brush
        "view marked:'Brush'"
    end
    def text
        "view marked:'Text'"
    end
   
    def crop
       "view marked:'Crop'"
    end
        
    #def modal_title
     #  "UILabel text:'Alert'" 
    #end
    
    #def modal_content
     # "label {text CONTAINS 'Do you want to return to preview and dismiss your edits?'}" 
    #end
    
    #def yes
     #   "UILabel text:'Yes'"
    #end
    
    #def no
    #    "UILabel text:'No'"
    #end
    
    #def add_text
     #   "UIButton marked:'Add text'"
    #end
       
    #def selected_frame
     #   "* id:'1_turquoise_frame'" 
    #end

    def save
        "view marked:'editor-tool-apply-btn'"
    end
#def download    
 #   "* id:'previewDownload'"
  #  end
  def cancel
       "view marked:'Discard photo'" 
    end
    def navigate
        unless current_page?
            preview_screen = go_to(GooglePreviewScreen)
            sleep(WAIT_SCREENLOAD)
            touch query("view marked:'Edit'")
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