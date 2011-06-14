require 'rubygems'
# require 'bson_ext'
require 'mongoid'
require 'database_cleaner'
require 'active_record'
require 'rspec'

require File.expand_path(File.join(__FILE__, "..", "..", "lib", "active_model_association_adapters"))

ActiveRecord::Base.establish_connection(
  :database => "db/active_model_association_adapters_test",
  :adapter  => "sqlite3"
)

ar_tables = ["monkeys", "file_thingies"]

ar_tables.each do |table_name|
  ActiveRecord::Base.connection.create_table table_name, :force => true do |t|
    t.string :name
  end
end

Mongoid.database = Mongo::Connection.new.db("active_model_association_adapters_test")

include DatabaseCleaner

RSpec.configure do |config|
  config.mock_with :rspec

  config.before(:all) do
    Mongoid.master.collections.reject { |c| c.name == 'system.indexes' }.each(&:drop)
  end
end
