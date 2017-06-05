require 'calabash-cucumber/ibase'

class GoogleSigninScreen < BaseHtmlScreen

  def screen_title
    sleep(10.0)
    device_agent.query({marked:"#{$list_loc['screen_title_signin']}" })
  end


  def fill_input_field(text,input_id)
    device_agent.touch({type: "TextField", index: 0 })
    sleep(STEP_PAUSE)
    username_arr = text.split('')
    i = 0
    while i < username_arr.length
      device_agent.touch({marked:"#{username_arr[i]}" })
      i = i + 1
    end   
  end
  def fill_password_field(text,input_id)

   device_agent.touch({type: "SecureTextField", index: 0 })
    sleep(STEP_PAUSE)
    passwrd_arr = text.split('')
    i = 0
    while i < passwrd_arr.length
      device_agent.touch({marked:"#{passwrd_arr[i]}" })
      i = i + 1
    end      
  end

  def google_auth_button
   device_agent.touch({marked:"#{$list_loc['allow']}" })
   sleep(5.0)
  end

  def navigate      
      await
  end
end
