module Mathetes; module Plugins
  class Give
    def initialize( mathetes )
      @mathetes = mathetes
      mathetes.hook_privmsg(
        :regexp => /^!give\b/
      ) do |message|
        handle_privmsg message
      end
    end

    def handle_privmsg( message )
      if message.text =~ /^\S+?\s+(.+)\s+to\s+(\S+?)\b$/
        nick = $2.strip
        thing = $1.strip
      elsif message.text =~ /^\S+?\s+(\S+?)\s+(.+)$/
        nick = $1.strip
        thing = $2.strip
      end

      if nick.nil? || thing.nil?
        if message.channel.nil?
          @mathetes.say("I shall do what?", message.from.nick)
        else
	  message.answer "I shall do what?"
        end
      elsif nick == @mathetes.nick
        if !message.channel.nil?
          message.answer "#{message.from.nick} just wanted that I give something to myself. Isn't that funny?"
        end
      elsif nick == message.from.nick
        if message.channel.nil?
          @mathetes.say("Sorry I have no #{thing} for you. Can I have some of it from you?", message.from.nick)
        else
          message.answer "#{message.from.nick}: Sorry I have no #{thing} for you. Can I have some of it from you?"
        end
      elsif message.channel.nil?
        @mathetes.say("I shall give you this #{thing} from #{message.from.nick}", nick)
      else
        user = message.channel.user(nick)
        if !user.nil? && message.channel.include?(user)
          @mathetes.action( "gives #{thing} to #{nick}", message.channel.name )
        else
          message.answer "#{message.from.nick}: Sorry I can't find #{nick} to give him #{thing}"
        end
      end
    end
  end
end; end
