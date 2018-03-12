require 'esa'
require 'yaml'

module NippouBot
  class Esa
    def self.ship_it!(md_text)
      Time.zone = ENV['TIME_ZONE'] || 'UTC'
      client = ::Esa::Client.new(access_token: ENV['ESA_ACCESS_TOKEN'], current_team: ENV['ESA_TEAM_NAME'])
      date = Time.zone.now
      data = {
        name:       "#{ENV['REPORT_NAME']}",
        body_md:    md_text,
        tags:       ['nippou_gen'],
        category:   "日報/#{date.year}/#{date.month}/#{date.day}",
        wip:        false,
        message:    '日報を書いたよ',
        #updated_by: 'esa_bot'
      }

      post = today_report

      if post.nil?
        response = client.create_post(data)
      else
        response = client.update_post(post['number'], data.merge({message: '日報を編集したよ'}))
      end

      if response.body.key?('error')
        puts response.body['message']
      end

      response.body['url'] || nil
    end

    def self.yesterday_todo
      client = ::Esa::Client.new(access_token: ENV['ESA_ACCESS_TOKEN'], current_team: ENV['ESA_TEAM_NAME'])
      screen_name = client.user.body['screen_name']

      yesterday_report = client.posts(q: "user:#{screen_name} category:日報").body['posts']&.first
      return if yesterday_report.nil?
      body_md = yesterday_report['body_md']

      start = false
      fin = false
      todo = []

      body_md.each_line do |line|
        if start | fin
          fin = line.match(/^##\s/)
          break if fin
          todo << line.gsub(/(\r\n|\r)/, "\n")
          next
        end
        start = line.include?('# 明日の作業予定')
      end

      todo.join(nil).chomp!
    end

    def self.today_report
      client = ::Esa::Client.new(access_token: ENV['ESA_ACCESS_TOKEN'], current_team: ENV['ESA_TEAM_NAME'])
      date = Time.zone.now
      screen_name = client.user.body['screen_name']
      post_category = "日報/#{date.year}/#{date.month}/#{date.day}"
      post_name = ENV['REPORT_NAME']
      client.posts(q: "user:#{screen_name} category:#{post_category} name:#{post_name}").body['posts']&.first
    end

    def self.my_posts
      client = ::Esa::Client.new(access_token: ENV['ESA_ACCESS_TOKEN'], current_team: ENV['ESA_TEAM_NAME'])
      client.posts(q: "user:#{@screen_name}")
    end

  end
end

