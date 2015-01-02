require 'bundler/setup'

$:.push(File.expand_path("../../lib", __FILE__))

require 'rspec'

require 'rails'
require 'active_support'

require 'allow'

GEM_ROOT = File.expand_path("../..", __FILE__)
ENV['RAILS_ENV'] = 'development'

#Rails.logger = Logger.new(STDOUT)
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
