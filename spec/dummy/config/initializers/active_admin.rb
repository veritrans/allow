require 'activeadmin'

ActiveAdmin.application.load_paths << Rails.root.join('app/admin').to_s

ActiveAdmin.setup do |config|
  config.site_title = "Dummy"

  config.authentication_method = :authenticate_admin_user!
  config.authorization_adapter = 'Allow::ActiveAdmin'
  config.current_user_method = :current_admin_user

  config.logout_link_path = :destroy_admin_user_session_path

end


class ActiveAdmin::BaseController < ::InheritedResources::Base

  def authenticate_admin_user!
    true
  end

  def current_admin_user
    DummyAdminUser.current
  end

end

=begin
# for running as `rails s`
DummyAdminUser.current = DummyAdminUser.new(:admin)

begin
  ActiveRecord::Migrator.migrate(Rails.root.join('db/migrate').to_s)
rescue => e
  p e
end
=end
