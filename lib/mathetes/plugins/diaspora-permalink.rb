require 'open-uri'
require 'nokogiri'

module Mathetes; module Plugins
  class DiasporaPermalink
    TRUNCATE_AFTER = 150
    def initialize( mathetes )
      mathetes.hook_privmsg( :regexp => /http.+\/(status_messages|p|posts)\/\d+/ ) do |message|
        if message.text =~ /(http.+\/status_messages\/\d+)/
	  link = $1.gsub('status_messages', 'p')
        elsif message.text =~ /(http.+\/posts\/\d+)/
          link = $1.gsub('posts', 'p')
        elsif message.text =~ /(http.+\/p\/\d+)/
          link = $1
        end
        if link
         text = Nokogiri::HTML( open(link) ).xpath( "//div[@id='show_text']/p" ).first().inner_text()
         text.gsub!(/<[^>]*>/, "")
         text.gsub!(/[\r\n]+/, " ")
         if text.length > TRUNCATE_AFTER
           text = text.slice(0..TRUNCATE_AFTER)
         end
         message.answer("[Diaspora] #{text}... #{link}")
       end
      end
    end
  end
end; end
