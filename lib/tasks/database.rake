require 'active_record'
require 'active_record/tasks/database_tasks'
require 'yaml'
require 'erb'

# Load database config
db_config_file = File.expand_path('../../config/database.yml', __dir__)
db_config = YAML.safe_load(ERB.new(File.read(db_config_file)).result)

# Configure ActiveRecord
ActiveRecord::Base.configurations = db_config
ActiveRecord::Tasks::DatabaseTasks.db_dir = 'db'
ActiveRecord::Tasks::DatabaseTasks.env = 'development'
ActiveRecord::Tasks::DatabaseTasks.root = File.expand_path('../..', __dir__)
ActiveRecord::Tasks::DatabaseTasks.migrations_paths = ['db/migrate']

namespace :db do
  desc "Create the databases (development & test)"
  task :create do
    ActiveRecord::Tasks::DatabaseTasks.create_current
    puts "Databases created successfully!"
  end

  desc "Drop the databases (development & test)"
  task :drop do
    ActiveRecord::Tasks::DatabaseTasks.drop_current
    puts "Databases dropped successfully!"
  end

  desc "Run migrations"
  task :migrate do
    # Connect to the development database
    ActiveRecord::Base.establish_connection(db_config['development'])
  
    # Use MigrationContext correctly
    migration_context = ActiveRecord::MigrationContext.new('db/migrate')
    migration_context.migrate
    puts "Migrations ran successfully!"
  end  
end
