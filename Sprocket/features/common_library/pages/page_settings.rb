    require 'calabash-cucumber/ibase'

class PageSettingsScreen < Calabash::IBase

  def trait
    page_settings
  end

  def page_settings
    "view marked:'Page Settings'"
  end

  def print_button
"view marked:'Print'"
    #"button marked:'Print'"
  end

  def help
    "label marked:'How to print from your iPhone'"
  end

  def size
    "tableViewCell label marked:'Paper Size'"
  end

   def paper_type
     "view marked:'Paper Type'"
   end

  def size_option size
    "tableViewCell marked:'#{size} photo'"
  end

  def first_size
    "tableViewCell index:0"
  end
  def number_of_copies
    query( "label {text CONTAINS 'Cop'}", :text)[0].to_i
  end

  def increment_button
    "view marked:'Increment'"
  end

  def decrement_button
    "view marked:'Decrement'"
  end

  def settings
    "view marked:'Settings'"
  end

  def about_link
    "view marked:'Learn More about Printing'"
  end

  def navigate
    unless current_page?
      share_screen = go_to(ShareScreen)
      touch share_screen.print

    end
    await
  end



end