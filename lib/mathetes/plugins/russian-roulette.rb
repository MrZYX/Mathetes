# russian-roulette.rb

# Kicks people based on public PRIVMSG regexps.

# By Pistos - irc.freenode.net#mathetes

module Mathetes; module Plugins

  class RussianRoulette
    REASONS = [
        'You just shot yourself!',
        'Suicide is never the answer.',
        'If you wanted to leave, you could have just said so...',
        "Good thing these aren't real bullets...",
        "That's gotta hurt...",
    ]
    ALSO_BAN = false
    BAN_TIME = 60 # seconds

    def initialize( mathetes )
      @mathetes = mathetes
      @bullets = 6
      @mathetes.hook_privmsg(
        :regexp => /^!roul(ette)?\b/
      ) do |message|
        pull_trigger message
      end
    end

    def pull_trigger( message )
      message.answer '*spin* ...'
      sleep 4
      has_bullet = ( rand( @bullets ) == 0 )
      if ! has_bullet
        message.answer "-click-"
        @bullets -= 1
      else
        @bullets = 6
        if ALSO_BAN
          @mathetes.ban(
            message.from,
            message.channel,
            BAN_TIME
          )
        end

        @mathetes.kick(
          message.from,
          message.channel,
          '{ *BANG* ' +
            REASONS[ rand( REASONS.size ) ] +
          '}'
        )
      end
    end

  end

end; end
