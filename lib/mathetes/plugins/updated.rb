require 'rubygems'
require 'mechanize'

module Mathetes; module Plugins
  class Updated
    def initialize( mathetes )
      mathetes.hook_privmsg(
        :regexp => /^!rev\b/
      ) do |message|
        if message.text =~ /^!rev (\S+)/
          info = get_info($1.strip)
          if info.key?('error')
            message.answer "Oh no! #{info['error']}"
          else
            if info.key?('rev') && info.key?('date')
              message.answer "The pod at #{$1.strip} runs on #{info['rev']} from #{info['date']}"
            else
              if info.key?('rev')
                message.answer "The pod at #{$1.strip} runs on #{info['rev']}"
              elsif info.key?('date')
                message.answer "The pod at #{$1.strip} was updated at #{info['date']}"
              else
                message.answer "#{$1.strip} is either not a Diaspora pod, a very old Diaspora pod or doesn't expose his revision."
              end
            end
          end
        else
          message.answer "Usage: !rev URL to a Diaspora pod"
        end
      end
    end

    def get_info(uri)
      begin
        uri = "http://#{uri}" unless uri.start_with?('http')
        uri = URI.parse uri
      rescue
        return {'error' => "I couldn't parse this URL"}
      end
      a = Mechanize.new { |agent|
        agent.user_agent_alias = 'Mac Safari'
      }
  
      begin
        p = a.get(uri)
      rescue Mechanize::ResponseCodeError
        begin
          p = a.get(uri.scheme+"://"+uri.host+"/users/password/new")
        rescue
          return {'error' => "I think this isn't a Diaspora pod."}
        end
      rescue Exception => e
        puts e
        return {'error' => "Something wen't terribly wrong :(. Or tried you to trick me?"}
      end
      ret = {}
      ret['rev'] = 'https://github.com/diaspora/diaspora/commit/'+p.header['x-git-revision'] if p.header.key?('x-git-revision')
      ret['date'] = Time.parse(p.header['x-git-update']).utc.strftime('%m/%d/%Y %H:%M UTC') if p.header.key?('x-git-update')
      ret
    end
  end
end; end
