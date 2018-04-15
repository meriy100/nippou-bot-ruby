require './lib/nippou_bot'

task :default do
  NippouBot::Engine.run
end

desc 'Migrate database'
task migrate: :environment do
  ActiveRecord::Migrator.migrate('db/migrate', ENV["VERSION"] ? ENV["VERSION"].to_i : nil)
end

task create: :environment do
  ActiveRecord::Base.connection.create_database 'nippou_bot_ruby'
end

task :environment do
  db_conf = YAML.load( ERB.new( File.read("./config/database.yml") ).result )

  # `rake ENV=development`/`rake ENV=production`で切り替え可能
  ActiveRecord::Base.establish_connection( db_conf["db"][ENV["ENV"]] )
  # ActiveRecord::Base.logger = Logger.new("log/database.log")
end

