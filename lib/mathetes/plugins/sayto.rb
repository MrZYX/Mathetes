module Mathetes; module Plugins
  class Saytochan
    ALLOWED = ['MrZYX', 'DenSchub']
    def initialize( mathetes )
      @mathetes = mathetes
      mathetes.hook_privmsg(
        :regexp => /^!sayto\b/
      ) do |message|
        if ALLOWED.include?( message.from.nick )
          if message.text =~ /^!sayto\s+(#[a-zA-Z0-9_-]+)\s+(.+)/
            @mathetes.say( $2, $1.strip )
          else
            @mathetes.say( "I cannot understand you, sorry.", message.from.nick )
          end
        else
          @mathetes.say( "No I won't do that!", message.from.nick )
        end
      end
    end
  end
end; end
