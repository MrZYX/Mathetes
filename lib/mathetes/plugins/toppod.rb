require 'nokogiri'
require 'open-uri'

module Mathetes; module Plugins
  class Toppod
    def initialize( mathetes )
      mathetes.hook_privmsg(
        :regexp => /^!t(p|oppod)\b/
      ) do |message|
        handle_privmsg message
      end
    end

    def handle_privmsg( message )
      doc = Nokogiri::HTML( open('http://podup.sargodarya.de/') )
      pod = doc.xpath("//tr[@id='pr1']/td[@class='podurl']/a").first()
      message.answer "The best pod at the moment according to http://podup.sargodarya.de is: #{pod.inner_text}" #-http://podup.sargodarya.de#{pod['href']}"
    end
  end
end; end
