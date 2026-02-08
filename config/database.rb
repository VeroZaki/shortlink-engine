require "yaml"
require "active_record"

env = ENV.fetch("APP_ENV", "development")

db_config = YAML.load_file("config/database.yml")
ActiveRecord::Base.establish_connection(db_config[env])
