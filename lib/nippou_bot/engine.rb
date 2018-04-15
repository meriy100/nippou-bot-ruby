require 'slack-ruby-bot'

require 'pry'


module NippouBot
  class Engine < SlackRubyBot::Bot
    command 'start' do |client, data, _|
      NippouBot::Command.new(client, data, _).start
    end

    command 'info' do |client, data, _|
      NippouBot::Command.new(client, data, _).info
    end

    command 'ping' do |client, data, _|
      NippouBot::Command.new(client, data, _).ping
    end

    scan /report user_set\s+(\S+)\s+(\S+)/ do |client, data, match|
      NippouBot::Command.new(client, data, _).user_set
    end

    scan(/(.*)/) do |client, data, _|
      NippouBot::Command.new(client, data, _).write_report
    end
  end
end
