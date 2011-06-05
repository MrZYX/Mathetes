require 'mutex-pstore'

module Mathetes; module Plugins

  class KeyValueStore

    def initialize( mathetes )
      @h = MuPStore.new( "key-value.pstore" )
      @mathetes = mathetes
      mathetes.hook_privmsg( :regexp => /^!keys\b/ ) do |message|
       keys = []
       @h.transaction {
         @h.roots.each { |root|
           item = eval(root)
           keys.push(item[:key]) if item[:channel] == message.channel.to_s
         }
       }
       message.answer "I know the following keys: #{keys.sort.join(', ')}"
      end
      mathetes.hook_privmsg( :regexp => /^(!i(nfo)?\b|\?\w+)(\s+\S+)?/ ) do |message|
        if message.text =~ /^(!i\s+|!info\s+|\?)(\w+)=(.+)/
          if !message.channel.nil?
	    key, value = $2.strip, $3.strip
            @h.transaction {
              @h[ { :channel => message.channel.to_s, :key => key }.inspect ] = value
            }
            message.answer "Set '#{key}'."
          else
            @mathetes.say( "Hm?", message.from.nick )
          end
        elsif message.text =~ /^(!i\s+|!info\s+|\?)(\w+)(\s+\S+)?/
          if !message.channel.nil?
            to = $3.strip if $3
            key = $2.strip
            value = nil
            @h.transaction {
              value = @h[ { :channel => message.channel.to_s, :key => key }.inspect ]
            }
            if value
              to += ": " if to
              to = "" unless to
              message.answer "#{to}#{value}"
            else
              message.answer "No value for key '#{key}'."
            end
          else
            @mathetes.say("Hm?", message.from.nick )
          end
        elsif message.text =~ /^(!i\s+|!info\s+|\?)(#[a-zA-Z0-9_-]+):(\w+?)=(.+)/
          chan, key, value = $2.strip, $3.strip, $4.strip
          @h.transaction {
            @h[ { :channel => chan.to_s, :key => key }.inspect ] = value
          }
          @mathetes.say( "Set '#{key}' for #{chan}", message.from.nick )
        elsif message.text =~ /^(!i\s+|!info\s+|\?)(#[a-zA-Z0-9_-]+):(\w+)/
         chan = $2.strip
         key = $3.strip
         value = nil
         @h.transaction {
           value = @h[ { :channel => chan.to_s, :key => key }.inspect ]
         }
         if value
          @mathetes.say( value, chan )
         else
          @mathetes.say( "No value for key '#{key}' for  #{chan}", message.from.nick )
         end
        else
          if message.channel.nil?
            @mathetes.say( "Usage: !i chan:key=value    !i chan:key", message.from.nick )
          else
            message.answer "Usage: !i key=value    !i key"
          end
        end
      end
    end

  end

end; end
