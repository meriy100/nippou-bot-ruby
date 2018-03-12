module NippouBot
end

require 'active_support'
require 'active_support/core_ext'
require 'erb'
require 'envyable'

Envyable.load('config/env.yml')
Time.zone = ENV['TIME_ZONE'] || 'UTC'

require './lib/nippou_bot/engine'
require './lib/nippou_bot/slack'
require './lib/nippou_bot/generator'
require './lib/nippou_bot/esa'
require './lib/nippou_bot/github'
