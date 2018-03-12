module NippouBot
end

require 'active_support'
require 'active_support/core_ext'
require 'erb'
require 'envyable'

Envyable.load('config/env.yml')
Time.zone = ENV['TIME_ZONE'] || 'UTC'

require './lib/nippou_bot/engine.rb'
require './lib/nippou_bot/slack.rb'
require './lib/nippou_bot/generator.rb'
require './lib/nippou_bot/esa.rb'
require './lib/nippou_bot/github.rb'
