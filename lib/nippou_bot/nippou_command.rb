module NippouBot
  class Command
    attr_accessor :client, :data, :match

    def initialize(client, data, match)
      self.client = client
      self.data = data
      self.match = match
    end

    def start
      User.find_by!(slack_user: data['user'])
      client.say(text: '本日の作業内容を教えてください', channel: data.channel)
    rescue ActiveRecord::RecordNotFound => _
      client.say(text: "ユーザー情報をセット してください.\nreport user_set $ESA_TOKEN $ESA_NAME", channel: data.channel)
    end

    def info
      client.say(text: info_message, channel: data.channel)
    rescue => e
      client.say(text: e, channel: data.channel)
    end

    def ping
      client.say(text: 'pong', channel: data.channel)
    end

    def user_set
      User.create!(slack_user: data['user'], esa_token: match.first[0], esa_name: match.first[1])
      client.say(text: 'ユーザー情報をセットしました', channel: data.channel)
    rescue => e
      client.say(text: e, channel: data.channel)
    end

    def write_report
      next_message = NippouBot::SlackAPI.new.next_message(data.channel, data.ts)
      case next_message
      when :end
        user = User.find_by!(slack_user: data['user'])
        reports = NippouBot::SlackAPI.new.get_reports(data.channel, data.ts, data.user)
        md = NippouBot::Generator.generate(reports)
        url = NippouBot::Esa.ship_it!(md, user)
        client.say(text: url, channel: data.channel)
      when :nothing
      else
        user = User.find_by!(slack_user: data['user'])
        client.say(text: next_message, channel: data.channel)
      end
    rescue ActiveRecord::RecordNotFound => e
      client.say(text: "ユーザー情報をセット してください.\nreport user_set $ESA_TOKEN $ESA_NAME", channel: data.channel)
    rescue => e
      client.say(text: "エラーが発生しました\n#{e}\n#{e.backtrace.join("\n")}", channel: data.channel)
    end

    private

    def info_message
<<EOS
users: #{NippouBot::SlackAPI.new.users}
EOS
    end
  end
end
