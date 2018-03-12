require 'slack-ruby-bot'

require 'pry'


module NippouBot
  class Engine < SlackRubyBot::Bot
    command 'report hi' do |client, data, match|
      client.say(text: '本日の作業内容を教えてください', channel: data.channel)
    end

    command 'ping' do |client, data, match|
      client.say(text: 'pong', channel: data.channel)
    end

    scan(/(.*)/) do |client, data, match|
      next_message = NippouBot::SlackAPI.new.next_message(data.channel, data.ts)
      case next_message
      when :end
        reports = NippouBot::SlackAPI.new.get_reports(data.channel, data.ts)
        md = NippouBot::Generator.generate(reports)
        client.say(text: md, channel: data.channel)
      when :nothing
        client.say(text: "Nothing", channel: data.channel)
      else
        client.say(text: next_message, channel: data.channel)
      end
    end
  end
end
