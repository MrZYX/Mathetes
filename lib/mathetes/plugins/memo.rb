require 'm4dbi'

module Mathetes; module Plugins

  class MemoManager
    # Add bot names to this list, if you like.
    IGNORED = [
        "",
        "*",
        "Gherkins",
        "Mathetes",
        "GeoBot",
        "scry",
    ]
    MAX_MEMOS_PER_PERSON = 20
    PUBLIC_READING_THRESHOLD = 2

    def initialize( mathetes )
      @mathetes = mathetes
      @mathetes.hook_privmsg(
        :regexp => /^!memo\b/
      ) do |message|
        record_memo message
      end
      @mathetes.hook_privmsg do |message|
        handle_privmsg message
      end
      @mathetes.hook_join do |message|
        handle_join message
      end

      @dbh = DBI.connect( "DBI:Pg:reby-memo:localhost", "memo2", "memo" )
    end

    def memos_for( recipient, channel )
      if channel =~ /\$(\d)/
        channel = $1.to_s
      end 
      @dbh.select_all(
        %{
          SELECT
            m.*,
            age( NOW(), m.time_sent )::TEXT AS sent_age
          FROM
            memos m
          WHERE
            (
              lower( m.recipient ) = lower( ? )
              OR ? ~* m.recipient_regexp
            )
            AND m.time_told IS NULL
            AND (m.channel IS NULL OR m.channel = lower( ? ))
        },
        recipient,
        recipient,
        channel
      )
    end

    def record_memo( privmsg )
      args = privmsg.text[ /^\S+\s+(.*)/, 1 ]

      sender = nick = privmsg.from.nick
      recipient, message = args.split( /\s+/, 2 )
      channel = privmsg.channel.name

      if sender.nil? || recipient.nil? || message.nil? || recipient.empty? || message.empty?
        privmsg.answer "#{nick}: !memo <recipient> <message>"
        return
      end

      if recipient =~ %r{^/(.*)/$}
        recipient_regexp = Regexp.new $1
        @dbh.do(
          "INSERT INTO memos ( sender, recipient_regexp, message, channel ) VALUES ( ?, ?, ?, ? )",
          sender,
          recipient_regexp.source,
          message,
          channel.to_s
        )
        privmsg.answer "#{nick}: Memo recorded for /#{recipient_regexp.source}/."
      else
        if memos_for( recipient, channel ).size >= MAX_MEMOS_PER_PERSON
          privmsg.answer "The inbox of #{recipient} is full."
        else
          @dbh.do(
            "INSERT INTO memos ( sender, recipient, message, channel ) VALUES ( ?, ?, ?, ? )",
            sender,
            recipient,
            message,
            channel.to_s
          )
          privmsg.answer "#{nick}: Memo recorded for #{recipient}."
        end
      end
    end

    def handle_privmsg( message )
      nick = message.from.nick
      return  if IGNORED.include?( nick )

      if message.channel
        dest = message.channel.name
      else
        dest = nil
      end

      memos = memos_for( nick, dest )
      if memos.size <= PUBLIC_READING_THRESHOLD && message.channel
        dest = message.channel.name
      else
        dest = nick
      end

      memos.each do |memo|
        age = memo[ 'sent_age' ].gsub( /\.\d+$/, '' )
        case age
        when /^00:00:(\d+)/
          age = "#{$1} seconds"
        when /^00:(\d+):(\d+)/
          age = "#{$1}m #{$2}s"
        else
          age.gsub( /^(.*)(\d+):(\d+):(\d+)/, "\\1 \\2h \\3m \\4s" )
        end
        @mathetes.say( "#{nick}: [#{age} ago] <#{memo['sender']}> #{memo['message']}", dest )
        @dbh.do(
          "UPDATE memos SET time_told = NOW() WHERE id = ?",
          memo[ 'id' ]
        )
      end
    end

    def handle_join( message )
      nick = message.from.nick
      channel = message.channel.name
      return  if IGNORED.include?( nick )

      memos = memos_for( nick, channel )
      if memos.size > 0
        @mathetes.say "You have #{memos.size} memo(s).  Speak publicly in a channel to retrieve them.", nick
      end
    end

  end

end; end
