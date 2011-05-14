require 'open-uri'
require 'nokogiri'

module Mathetes
  module Plugins
    class OkToUpdate
      def initialize(mathetes)
        mathetes.hook_privmsg(:regexp => /^!oktoupdate\b/) do |msg|
          open 'http://isitoktoupdatemydiaspora.tk/' do |io|
            msg.answer Nokogiri::HTML(io).css('#content > h1:first').text.strip
          end
        end
      end
    end
  end
end
