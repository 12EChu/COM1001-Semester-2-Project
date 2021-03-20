# Configure coverage logging
require "simplecov"
SimpleCov.start do
  add_filter "/spec/"
end
SimpleCov.coverage_dir "coverage"

# Ensure we use the test database
ENV["APP_ENV"] = "test"

# load the app
require_relative "../app"

# load the test db
init_db

# Configure Capybara
require "capybara/rspec"
Capybara.app = Sinatra::Application
Capybara.configure do |config|
  config.save_path = ("capybara/")
end

# Configure RSpec
def app
  Sinatra::Application
end
RSpec.configure do |config|
  config.include Capybara::DSL
  config.include Rack::Test::Methods
end
