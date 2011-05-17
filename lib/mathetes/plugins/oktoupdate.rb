require 'open-uri'
require 'nokogiri'

module Mathetes
  module Plugins
    class OkToUpdate
      def initialize(mathetes)
        mathetes.hook_privmsg(:regexp => /^!oktoupdate\b/) do |msg|
          open 'http://isitoktoupdatemydiaspora.tk/' do |io|
            n = Nokogiri::HTML(io)
            mesg = n.css('#content > h1:first').text.strip
            date = n.css('#content > p:first').text.strip
            msg.answer "#{mesg} - #{date}"
          end
        end
      end
    end
  end
end
