require 'slack-ruby-bot'

require 'pry'


module NippouBot
  class Engine < SlackRubyBot::Bot
    command 'report' do |client, data, _|
      client.say(text: '本日の作業内容を教えてください', channel: data.channel)
    end

    command 'info' do |client, data, _|
      begin
        client.say(text: info_message, channel: data.channel)
      rescue => e
        client.say(text: e, channel: data.channel)
      end
    end

    command 'ping' do |client, data, _|
      client.say(text: 'pong', channel: data.channel)
    end

    scan(/(.*)/) do |client, data, _|
      begin
        next_message = NippouBot::SlackAPI.new.next_message(data.channel, data.ts)
        case next_message
        when :end
          reports = NippouBot::SlackAPI.new.get_reports(data.channel, data.ts)
          github_events = NippouBot::Github.events
          reports['github_events'] = github_events
          md = NippouBot::Generator.generate(reports)
          url = NippouBot::Esa.ship_it!(md)
          client.say(text: url, channel: data.channel)
        when :nothing
          client.say(text: 'Nothing', channel: data.channel)
        else
          client.say(text: next_message, channel: data.channel)
        end
      rescue => e
        client.say(text: "エラーが発生しました\n#{e}", channel: data.channel)
      end
    end

    private

    def self.info_message
<<EOS
users: #{NippouBot::SlackAPI.new.users}
EOS
    end
  end
end
