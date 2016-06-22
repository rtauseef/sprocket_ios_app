require 'calabash-cucumber/ibase'

class SearchScreen < Calabash::IBase

  def trait
    search_screen
  end

  def search_screen
    "navigationItemView marked:'Search'"
  end

    def search_result
    $name= query("tableViewCell index:0",:text).first
    end

  def navigate
    unless current_page?
      select_photo = go_to(HomeScreen)
      touch select_photo.search
    end
    await
  end

end
