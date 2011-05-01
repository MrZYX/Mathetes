require 'open-uri'
require 'nokogiri'

module Mathetes; module Plugins
  class TranslationStatus
     PROJECT_ID = 181
    def initialize( mathetes )
      @mathetes = mathetes
      mathetes.hook_privmsg(
        :regexp => /^!(ts|trans(lation)?stat(i)?s(tics)?)\b/
      ) do |message|
	if message.text =~ /\S+\s+([a-zA-Z_-]+)/
          url = "http://99translations.com/public_projects/show/#{PROJECT_ID}"
          doc = Nokogiri::HTML( open( url ) )
          status = doc.xpath("//table/tr[td=' #{$1.strip}']/td/span").inner_text.strip
          key = $1.strip
          if status.nil? || status == ''
            if key == 'en'
              status = '100%'
            end
          end
          if status.nil? || status == ''
            if message.channel.nil?
              @mathetes.say("There is currently no translation for #{key}. Create one! Have a look at https://github.com/diaspora/diaspora/wiki/How-to-contribute-translations", message.from.nick)
            else
              message.answer "There is currently no translation for #{key}. Create one! Have a look at https://github.com/diaspora/diaspora/wiki/How-to-contribute-translations"
            end
          elsif status == '100%'
            if message.channel.nil?
              @mathetes.say("The translation for #{key} is currently at #{status}", message.from.nick)
            else
              message.answer "The translation for #{key} is currently at #{status}"
            end
          else
            if message.channel.nil?
              @mathetes.say("The translation for #{key} is currently at #{status}. Get it to 100% at http://http://99translations.com/public_projects/show/#{PROJET_ID}", message.from.nick)
            else
              message.answer "The translation for #{key} is currently at #{status}. Get it to 100% at http://99translations.com/public_projects/show/#{PROJECT_ID}"
            end
          end
        else
          if message.channel.nil?
            @mathetes.say("You have to provide a language code!", message.from.nick)
          else
            message.answer "You have to provide a language code!"
          end
        end
      end
    end
  end
end; end
