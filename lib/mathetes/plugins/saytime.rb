require 'time'

module Mathetes; module Plugins
  class Saytime
    def initialize( mathetes )
      mathetes.hook_privmsg(
        :regexp => /^!time\b/
      ) do |message|
        time = Time.new
        message.answer "#{message.from.nick}: Es ist #{time.strftime("%H Uhr %M und %S Sekunden")}"
      end
      mathetes.hook_privmsg(
       :regexp => /^!date\b/
      ) do |message|
        time = Time.new
        message.answer "#{message.from.nick}: Wir haben den #{time.strftime("%d.%m.%Y")}"
      end
    end
  end
end; end
