require 'slack'
require 'yaml'

Slack.configure do |config|
  config.token = ENV['SLACK_API_TOKEN']
end

module NippouBot
  class SlackAPI
    def initialize
      @client = Slack::Web::Client.new(user_agent: 'Slack Ruby Client/1.0')
    end

    def channels
      @channels ||= @client.channels_list["channels"]
    end

    def conversations_history_lasted(channel_id, ts)
      messages = @client.conversations_history(channel: channel_id)['messages'].reverse
      message = messages.select { |m| m['user'] == ENV['BOT_USER_ID'] }.last
      if story = stories.find { |s| s['message'].match(message['text']) }
        if next_story = stories.find { |s| s['id'] == story['id'] + 1 }
          next_story['message']
        else
          nippou = []
          messages[-10..-1].each_cons(2) do |first, second|
            if s = stories.find { |s| first['user'] == ENV['BOT_USER_ID'] && s['message'].match(first['text']) }
              nippou.push(bot: s, body: second['text'])
            end
          end
          nippou
        end
      else
        'Nothing'
      end
    end

    def times_channel
      @times_channel ||= channels.find { |channel| channel["name"] == ENV['SLACK_TIMES_NAME'] }
    end

    private

    def stories
      YAML.load_file('config/story.yml')
    end

    def owner_id
      @owner_id ||= users.find { |_, name| name == ENV['SLACK_USER_NAME'] }.first
    end

    def begin_ts
      Time.zone.now.beginning_of_day.to_i
    end

    def end_ts
      Time.zone.now.end_of_day.to_i
    end
  end
end

if __FILE__ == $0
  require './lib/nippou_bot'
  puts NippouBot::SlackAPI.new.conversations_history_lasted('D9B3Z5NLT', '').to_json
end
