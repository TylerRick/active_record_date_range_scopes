require 'bundler'
require 'bundler/setup'
Bundler.require(:default, :development)

require 'rails/all'

#---------------------------------------------------------------------------------------------------

__DIR__ = Pathname.new(__FILE__).dirname
$LOAD_PATH.unshift __DIR__
$LOAD_PATH.unshift __DIR__ + '../lib'

#---------------------------------------------------------------------------------------------------
# ActiveRecord

require 'active_record'

log_file_path = __DIR__ + 'log/test.log'
log_file_path.truncate(0) rescue nil
ActiveRecord::Base.logger = Logger.new(log_file_path)
#ActiveRecord::Base.logger = Logger.new($stdout)

driver = (ENV["DB"] or "sqlite3").downcase
database_config = YAML::load(File.open(__DIR__ + "support/database.#{driver}.yml"))
ActiveRecord::Base.establish_connection(database_config)

require __DIR__ + 'support/schema'

#---------------------------------------------------------------------------------------------------
# RSpec

require 'rspec'
require 'rspec/rails'

RSpec.configure do |config|
  config.example_status_persistence_file_path = "tmp/rspec_status.txt"
  config.use_transactional_examples = true
end

Dir[__DIR__ + 'support/**/*.rb'].each do |f|
  require f
end
