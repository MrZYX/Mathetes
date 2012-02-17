require 'net/http'
require 'net/https'
require 'open-uri'
require 'nokogiri'
require 'yaml'

module Mathetes; module Plugins
  class TranslationStatus
    API_KEY = "66c5e5731ada866d7a0be466f4fc4fb0abb22e76"
    PROJECT = "3020-Diaspora"

    def initialize( mathetes )
      @mathetes = mathetes
      mathetes.hook_privmsg(
        :regexp => /^!(ts|trans(lation)?stat(i)?s(tics)?)\b/
      ) do |message|
	if message.text =~ /\S+\s+([\d\w_-]+)/
          key = $1.strip.gsub("_", "-")
          url = "https://webtranslateit.com/api/projects/#{API_KEY}/stats.yaml"
          content = open(url).read
          stats = YAML.load content
          if key != "en" && stats.keys.include?(key)
            stats = stats[key]
            if stats['count_strings_done'] == stats['count_strings']
              answer = "The translation for #{key} is complete :)."
            else
              answer = "The translation for #{key} has #{stats['count_strings_done']}/#{stats['count_strings']} keys done, with #{stats['count_strings_to_translate']} untranslated and #{stats['count_strings_to_proofread']} to proofread."
            end

            answer += " Join the team at https://webtranslateit.com/en/projects/#{PROJECT} to further improve it!"
          elsif key == "en"
            answer = "English is the master translation ;)"
          else
            answer = "There so no translation for #{key} yet. Have a look at https://github.com/liamnic/IntrestIn/wiki/How-to-contribute-translations on how to create it!"
          end
        else
          answer = "You have to provide a language code!"
        end
        
        if message.channel.nil?
          @mathetes.say answer, message.from.nick
        else
          message.answer answer
        end
      end
    end
  end
end; end
