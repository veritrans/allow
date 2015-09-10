require 'rails/all'

if defined?(Bundler)
  Bundler.require(*Rails.groups(assets: %w[development test]))
end

module RailsApp
  class Application < Rails::Application
    config.encoding = 'utf-8'

    config.filter_parameters += [:password]

    config.assets.enabled = true

    config.assets.version = '1.0'
    config.secret_key_base = 'fuuuuuuuuuuu'

    # test.rb
    config.cache_classes = true
    config.eager_load = false

    config.serve_static_files = true
    config.static_cache_control = 'public, max-age=3600'

    config.consider_all_requests_local       = true
    config.action_controller.perform_caching = false

    config.action_dispatch.show_exceptions = false

    config.action_controller.allow_forgery_protection    = false

    config.action_mailer.delivery_method = :test

    config.active_support.deprecation = :stderr
    I18n.enforce_available_locales = false

    config.active_support.test_order = :sorted
  end
end
