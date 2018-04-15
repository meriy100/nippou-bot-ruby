module NippouBot
end

require 'active_support'
require 'active_support/core_ext'
require 'erb'
require 'envyable'
require 'mysql2'
require 'active_record'

Envyable.load('config/env.yml')
Time.zone = ENV['TIME_ZONE'] || 'UTC'

db_conf = YAML.load(ERB.new(File.read('./config/database.yml')).result)

# `rake ENV=development`/`rake ENV=production`で切り替え可能
ActiveRecord::Base.establish_connection(db_conf['db'][ENV['ENV']])
# ActiveRecord::Base.logger = Logger.new("log/database.log")

require './lib/nippou_bot/engine'
require './lib/nippou_bot/slack'
require './lib/nippou_bot/generator'
require './lib/nippou_bot/esa'
require './lib/nippou_bot/github'
require './lib/models/user'
