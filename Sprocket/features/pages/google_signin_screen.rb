require 'calabash-cucumber/ibase'

class GoogleSigninScreen < BaseHtmlScreen

  def screen_title
    sleep(10.0)
    device_agent.query({marked:"Sign in - Google Accounts" })
  end


  def fill_input_field(text,input_id)

    device_agent.touch({type: "TextField", index: 0 })
    sleep(STEP_PAUSE)
    device_agent.touch({marked:"l" })
    device_agent.touch({marked:"o" })
    device_agent.touch({marked:"k" })
    device_agent.touch({marked:"i" })
    device_agent.touch({marked:"a" })
    device_agent.touch({marked:"u" })
    device_agent.touch({marked:"t" })
    device_agent.touch({marked:"o" })
    device_agent.touch({marked:"m" })
    device_agent.touch({marked:"a" })
    device_agent.touch({marked:"t" })
    device_agent.touch({marked:"i" })
    device_agent.touch({marked:"o" })
    device_agent.touch({marked:"n" })
    device_agent.touch({marked:"t" })
    device_agent.touch({marked:"e" })
    device_agent.touch({marked:"s" })
    device_agent.touch({marked:"t" })
  end
  def fill_password_field(text,input_id)

   device_agent.touch({type: "SecureTextField", index: 0 })
    sleep(STEP_PAUSE)
    device_agent.touch({marked:"l" })
    device_agent.touch({marked:"o" })
    device_agent.touch({marked:"k" })
    device_agent.touch({marked:"i" })
    device_agent.touch({marked:"t" })
    device_agent.touch({marked:"e" })
    device_agent.touch({marked:"s" })
    device_agent.touch({marked:"t" })
    device_agent.touch({marked:"e" })
    device_agent.touch({marked:"r" })
    
  end

  def google_auth_button
   device_agent.touch({marked:"ALLOW" })
   sleep(5.0)
  end

  def navigate
      
      await
  end
end
