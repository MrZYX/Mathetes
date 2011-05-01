# This script polls RSS feeds, echoing new items to IRC.

# By Pistos - irc.freenode.net#mathetes

require 'mvfeed'

module Mathetes; module Plugins

  class RSS

    FEEDS = {
#      'https://blog.geraspora.de/feed' => {
#          :channels => [ '#diaspora-de' ],
#          :interval => 60*60,
#      },
'http://pipes.yahoo.com/pipes/pipe.run?_id=635e9046ec5d356d5048f2f702332ebb&_render=rss' => {
          :channels => [ '#diaspora-de' ],
          :interval => 60*15,
    }

    def initialize( mathetes )
      @mathetes = mathetes
      @seen = Hash.new { |hash,key| hash[ key ] = Hash.new }
      @first = Hash.new { |hash,key| hash[ key ] = true }

      FEEDS.each do |uri, data|
        mathetes.new_thread do
          loop do
            poll_feed( uri, data )
            sleep data[ :interval ]
          end
        end
      end
    end

    def poll_feed( uri, data )
      feed = Feed.parse( uri )
      feed.children.each do |item|
        say_item uri, item, data[ :channels ]
      end
      @first[ uri ] = false
    rescue Exception => e
      $stderr.puts "RSS plugin exception: #{e.message}"
      $stderr.puts e.backtrace.join( "\n\t" )
    end

    def zepto_url( url )
      URI.parse( 'http://z.pist0s.ca/zep/1?uri=' + CGI.escape( url ) ).read
    end

    def say_item( uri, item, channels )
      return  if ! item.respond_to? :link

      if item.respond_to?( :author ) && item.author
        author = "<#{item.author}> "
      end

      alert = nil

      channels.each do |channel|
        id = item.link
        if ! @seen[ channel ][ id ]
          if ! @first[ uri ]
            if alert.nil?
              url = item.link
              if url.length > 28
                url = zepto_url( item.link )
              end
              alert = "[\00300rss\003] #{author}#{item.title} - #{url}".gsub( /\n/, '' )
            end
            @mathetes.say alert, channel
          end
          @seen[ channel ][ id ] = true
        end
      end
    end
  end

end; end
