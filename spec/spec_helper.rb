require 'bundler/setup'

$:.push(File.expand_path("../../lib", __FILE__))

require 'rspec'

require 'rails'
require 'active_support'

require 'allow'

GEM_ROOT = File.expand_path("../..", __FILE__)
ENV['RAILS_ENV'] = 'test'

Rails.logger = Logger.new(StringIO.new)

module SpecHelpers
  def be_true
    be_truthy
  end

  def be_false
    be_falsey
  end
end

RSpec.configure do |config|
  config.mock_with :rspec

  config.expect_with :rspec do |c|
    c.syntax = [:should, :expect]
  end

  config.mock_with :rspec do |c|
    c.syntax = [:should, :expect]
  end

  config.include SpecHelpers

  config.add_setting :rendering_views, default: false
  def config.render_views?
    rendering_views
  end
end

def load_dummy_rails_app
  require 'kaminari'
  require 'inherited_resources'

  require 'dummy/config/environment'
  ActiveRecord::Migration.verbose = false
  ActiveRecord::Base.logger = Logger.new(nil)
  ActiveRecord::Migrator.migrate(File.expand_path('../dummy/db/migrate', __FILE__))

  #ActiveRecord::Base.logger = Logger.new(STDOUT)
  #Rails.logger = Logger.new(STDOUT)
end
