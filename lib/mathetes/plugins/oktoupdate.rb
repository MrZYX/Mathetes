require 'open-uri'
require 'nokogiri'

module Mathetes
  module Plugins
    class OkToUpdate
      def initialize(mathetes)
        mathetes.hook_privmsg(:regexp => /^!(isit)?(safe|ok|okay)to(update|pull)(my)?(diaspora)?\b/) do |msg|
          open 'http://isitoktoupdatemydiaspora.tk/' do |io|
            n = Nokogiri::HTML(io)
            mesg = n.css('#content > h1:first').text.strip
            exp = n.css('#explanation').text.gsub('Explanation:', '').strip
            date = n.css('#updated').text.strip
            unless exp.empty?
              msg.answer "#{mesg} - #{exp} - #{date}"
            else
              msg.answer "#{mesg} - #{date}"
            end
          end
        end
      end
    end
  end
end
