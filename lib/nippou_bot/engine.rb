require 'slack-ruby-bot'

require 'pry'

require './lib/nippou_bot/slack'

module NippouBot
  class Engine < SlackRubyBot::Bot
    command 'report hi' do |client, data, match|
      client.say(text: '本日の作業内容を教えてください', channel: data.channel)
    end

    command 'ping' do |client, data, match|
      client.say(text: 'pong', channel: data.channel)
    end

    scan(/(.*)/) do |client, data, match|
      client.say(text: NippouBot::SlackAPI.new.conversations_history_lasted(data.channel, data.ts), channel: data.channel)
    end
  end
end
