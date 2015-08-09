require 'activeadmin'

ActiveAdmin.setup do |config|
  config.site_title = "Dummy"

  config.authentication_method = :authenticate_admin_user!
  config.authorization_adapter = 'Allow::ActiveAdmin'
  config.current_user_method = :current_admin_user

  config.logout_link_path = :destroy_admin_user_session_path

  config.show_comments_in_menu = false

end


class ActiveAdmin::BaseController < ::InheritedResources::Base

  def authenticate_admin_user!
    true
  end

  def current_admin_user
    DummyAdminUser.current
  end

end
