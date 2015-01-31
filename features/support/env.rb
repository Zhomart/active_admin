# IMPORTANT: This file is generated by cucumber-rails - edit at your own peril.
# It is recommended to regenerate this file in the future when you upgrade to a
# newer version of cucumber-rails. Consider adding your own code to a new file
# instead of editing this one. Cucumber will automatically load all features/**/*.rb
# files.

ENV["RAILS_ENV"] ||= "cucumber"

require File.expand_path('../../../spec/spec_helper', __FILE__)

require 'rails'
require 'active_record' unless ENV['MONGOID']
require 'mongoid' if ENV['MONGOID']

orm_name = defined?(::ActiveRecord) ? 'activerecord' : 'mongoid'
orm_version = defined?(::ActiveRecord) ? ::ActiveRecord.version : ::Mongoid::VERSION
ENV['RAILS_ROOT'] = File.expand_path("../../../spec/rails/rails-#{Rails::VERSION::STRING}-#{orm_name}-#{orm_version}", __FILE__)

# Create the test app if it doesn't exists
unless File.exists?(ENV['RAILS_ROOT'])
  require 'rake'
  load File.expand_path( "../../tasks/test.rake", __FILE__)
  Rake::Task["setup"].invoke
end

require 'rails'
require 'active_record' unless ENV['MONGOID']
require 'mongoid' if ENV['MONGOID']
require 'active_admin'
require 'devise'
ActiveAdmin.application.load_paths = [ENV['RAILS_ROOT'] + "/app/admin"]

require ENV['RAILS_ROOT'] + '/config/environment'

# Setup autoloading of ActiveAdmin and the load path
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
autoload :ActiveAdmin, 'active_admin'

require 'cucumber/rails'

require 'rspec/mocks'
World(RSpec::Mocks::ExampleMethods)

Before do
  RSpec::Mocks.setup
end

After do
  begin
    RSpec::Mocks.verify
  ensure
    RSpec::Mocks.teardown
  end
end

require 'capybara/rails'
require 'capybara/cucumber'
require 'capybara/session'
require 'capybara/poltergeist'
require 'phantomjs/poltergeist'

Capybara.javascript_driver = :poltergeist

# Capybara defaults to XPath selectors rather than Webrat's default of CSS3. In
# order to ease the transition to Capybara we set the default here. If you'd
# prefer to use XPath just remove this line and adjust any selectors in your
# steps to use the XPath syntax.
Capybara.default_selector = :css

# If you set this to false, any error raised from within your app will bubble
# up to your step definition and out to cucumber unless you catch it somewhere
# on the way. You can make Rails rescue errors and render error pages on a
# per-scenario basis by tagging a scenario or feature with the @allow-rescue tag.
#
# If you set this to true, Rails will rescue all errors and render error
# pages, more or less in the same way your application would behave in the
# default production environment. It's not recommended to do this for all
# of your scenarios, as this makes it hard to discover errors in your application.
ActionController::Base.allow_rescue = false

# If you set this to true, each scenario will run in a database transaction.
# You can still turn off transactions on a per-scenario basis, simply tagging
# a feature or scenario with the @no-txn tag. If you are using Capybara,
# tagging with @culerity or @javascript will also turn transactions off.
#
# If you set this to false, transactions will be off for all scenarios,
# regardless of whether you use @no-txn or not.
#
# Beware that turning transactions off will leave data in your database
# after each scenario, which can lead to hard-to-debug failures in
# subsequent scenarios. If you do this, we recommend you create a Before
# block that will explicitly put your database in a known state.
Cucumber::Rails::World.use_transactional_fixtures = false unless ENV['MONGOID']
# How to clean your database when transactions are turned off. See
# http://github.com/bmabey/database_cleaner for more info.
if defined?(::ActiveRecord::Base)
  begin
    require 'database_cleaner'
    require 'database_cleaner/cucumber'
    DatabaseCleaner.strategy = :truncation
  rescue LoadError => ignore_if_database_cleaner_not_present
  end
end

if defined?(::Mongoid)
  ::Mongoid.default_session.drop
end

# Warden helpers to speed up login
# See https://github.com/plataformatec/devise/wiki/How-To:-Test-with-Capybara
include Warden::Test::Helpers

After do
  Warden.test_reset!

  # Reset back to the default auth adapter
  ActiveAdmin.application.namespace(:admin).
    authorization_adapter = ActiveAdmin::AuthorizationAdapter
end

Before do

  begin
    # We are caching classes, but need to manually clear references to
    # the controllers. If they aren't clear, the router stores references
    ActiveSupport::Dependencies.clear

    # Reload Active Admin
    ActiveAdmin.unload!
    ActiveAdmin.load!
  rescue
    p $!
    raise $!
  end
end

# improve the performance of the specs suite by not logging anything
# see http://blog.plataformatec.com.br/2011/12/three-tips-to-improve-the-performance-of-your-test-suite/
Rails.logger.level = 4

# Improves performance by forcing the garbage collector to run less often.
unless ENV['DEFER_GC'] == '0' || ENV['DEFER_GC'] == 'false'
  require File.expand_path('../../../spec/support/deferred_garbage_collection', __FILE__)
  Before { DeferredGarbageCollection.start }
  After  { DeferredGarbageCollection.reconsider }
end

# Don't run @rails4 tagged features for versions before Rails 4.
Before('@rails4') do |scenario|
  scenario.skip_invoke! if Rails::VERSION::MAJOR < 4
end

Around '@silent_unpermitted_params_failure' do |scenario, block|
  original = ActionController::Parameters.action_on_unpermitted_parameters
  ActionController::Parameters.action_on_unpermitted_parameters = false
  block.call
  ActionController::Parameters.action_on_unpermitted_parameters = original
end
