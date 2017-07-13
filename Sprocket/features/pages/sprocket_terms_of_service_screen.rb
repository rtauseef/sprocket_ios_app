require_relative '../common/base_html_screen'

class SprocketTermsOfServiceScreen < BaseHtmlScreen

  def trait
        sprocket_header
  end

  def sprocket_title
    "view marked:'sprocket'"
  end


  def sprocket_header
    "view marked:'#{$list_loc['terms_of_service_title']}'"
  end
  
  def done_button
    "view marked:'Done'"
    end

  def navigate
    if not current_page?
      landing_screen = go_to(LandingScreen)
      landing_screen.terms_of_service_link
       sleep(WAIT_SCREENLOAD)
    end
    await
  end
end
