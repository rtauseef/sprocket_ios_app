require 'calabash-cucumber/ibase'

class FlickrSelectTemplateScreen < Calabash::IBase

  def trait
    select_template
  end

  def select_template
    "navigationBar marked:'Select Template'"
  end

  def share_icon
    "view marked:'Share.png'"
  end

  def template_applied
    query("view marked:'Photo View'").first["frame"]["width"]
  end

  def text_area
    touch("textView marked:'description'")
  end

  def navigate
    unless current_page?
      select_photo_screen = go_to(FlickrPhotoScreen)
      wait_for_elements_exist(select_photo_screen.second_photo, :timeout => MAX_TIMEOUT)
      touch select_photo_screen.second_photo
    end
      await
  end

  def selected_template
    query("collectionView marked:'TemplateCollectionView'",:accessibilityValue).first
  end
end