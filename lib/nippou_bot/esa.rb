require 'esa'
require 'yaml'

module NippouBot
  class Esa
    def self.ship_it!(md_text, user)
      Time.zone = ENV['TIME_ZONE'] || 'UTC'
      client = ::Esa::Client.new(access_token: user.esa_token, current_team: ENV['ESA_TEAM_NAME'])
      date = Time.zone.now
      data = {
        name:       "#{user.esa_name}",
        body_md:    md_text,
        tags:       ['nippou_gen'],
        category:   "日報/#{date.year}/#{date.month}/#{date.day}",
        wip:        false,
        message:    '日報を書いたよ',
        #updated_by: 'esa_bot'
      }

      response = client.create_post(data)

      if response.body.key?('error')
        puts response.body['message']
      end

      response.body['url'] || nil
    end
  end
end

