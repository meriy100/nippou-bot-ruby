require 'slack-ruby-bot'

require 'pry'


module NippouBot
  class Engine < SlackRubyBot::Bot
    command 'report start' do |client, data, _|
      begin
        User.find_by!(slack_user: data['user'])
        client.say(text: '本日の作業内容を教えてください', channel: data.channel)
      rescue ActiveRecord::RecordNotFound => _
        client.say(text: "ユーザー情報をセット してください.\nreport user_set $ESA_TOKEN $ESA_NAME", channel: data.channel)
      end
    end

    command 'report info' do |client, data, _|
      begin
        client.say(text: info_message, channel: data.channel)
      rescue => e
        client.say(text: e, channel: data.channel)
      end
    end

    command 'report ping' do |client, data, _|
      client.say(text: 'pong', channel: data.channel)
    end

    scan /report user_set\s+(\S+)\s+(\S+)/ do |client, data, match|
      begin
        User.create!(slack_user: data['user'], esa_token: match.first[0], esa_name: match.first[1])
        client.say(text: 'ユーザー情報をセットしました', channel: data.channel)
      rescue => e
        client.say(text: e, channel: data.channel)
      end
    end

    scan(/(.*)/) do |client, data, _|
      begin
        user = User.find_by!(slack_user: data['user'])
        next_message = NippouBot::SlackAPI.new.next_message(data.channel, data.ts)
        case next_message
        when :end
          reports = NippouBot::SlackAPI.new.get_reports(data.channel, data.ts)
          github_events = NippouBot::Github.events
          reports['github_events'] = github_events
          md = NippouBot::Generator.generate(reports)
          url = NippouBot::Esa.ship_it!(md, user)
          client.say(text: url, channel: data.channel)
        when :nothing
        else
          client.say(text: next_message, channel: data.channel)
        end
      rescue ActiveRecord::RecordNotFound => e
        client.say(text: "ユーザー情報をセット してください.\nreport user_set $ESA_TOKEN $ESA_NAME", channel: data.channel)
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
