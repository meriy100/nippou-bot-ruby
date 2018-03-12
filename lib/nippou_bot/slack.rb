require 'slack'
require 'yaml'
require 'active_support'
require 'active_support/core_ext'

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

    def messages(channel_id)
       @client.conversations_history(channel: channel_id)['messages']
    end

    def get_reports(channel_id, ts)
      reports = []
      messages(channel_id).each_cons(2) do |user, bot|
        if s = stories.find { |s| bot['user'] == ENV['BOT_USER_ID'] && s['message'].match(bot['text']) }
          reports.push( s.merge('text' => user['text']) )
        end
      end
      reports.each.with_object({}) do |report, ob|
        next if ob[report['type']].present?
        ob[report['type']] = report
      end
    end

    def next_message(channel_id, ts)
      message = messages(channel_id).select { |m| m['user'] == ENV['BOT_USER_ID'] }.first
      if story = stories.find { |s| s['message'].match(message['text']) }
        if next_story = stories.find { |s| s['id'] == story['id'] + 1 }
          next_story['message']
        else
          :end
        end
      else
        :nothing
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
