require_relative '../common/base_html_screen'

class SprocketTermsOfServiceScreen < BaseHtmlScreen

  def trait
    sprocket_title
    sprocket_header
      done_button
  end

  def sprocket_title
    "UIWebView css:'DIV' {textContent LIKE 'sprocket'}"
  end


  def sprocket_header
    "UIWebView css:'H3' {textContent LIKE 'sprocket Terms of Service'}"
  end
  
  def done_button
    "UINavigationButton"
    end

  def navigate
    if not current_page?
      landing_screen = go_to(LandingScreen)
      landing_screen.terms_of_service
       sleep(WAIT_SCREENLOAD)
    end
    await
  end
end
