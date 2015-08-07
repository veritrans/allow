require 'activeadmin'

ActiveAdmin.setup do |config|
  config.site_title = "Dummy"

  config.authentication_method = :authenticate_admin_user!
  config.authorization_adapter = 'Allow::ActiveAdmin'
  config.current_user_method = :current_admin_user

  config.logout_link_path = :destroy_admin_user_session_path

  config.show_comments_in_menu = false

  #config.ignore_undefined_method_for_nil = true

end


class ActiveAdmin::BaseController < ::InheritedResources::Base

  def authenticate_admin_user!
    true
  end

  def current_admin_user
    DummyAdminUser.current
  end

  def check_permission
    # nothing
  end

  def action_methods
    set = super
    set << 'edit'
    set
  end
end

=begin
module ActiveAdmin
  class Router

    def define_root_routes(router)
      router.instance_exec @application.namespaces.values do |namespaces|
        namespaces.each do |namespace|
          if namespace.root?
            root :to => namespace.root_to
          else
            namespace namespace.name do
              get '/' => namespace.root_to
            end
          end
        end
      end
    end
  end
end
=end

=begin
ActiveAdmin::ResourceController.class_eval do
  before_action :check_permission_again

  def supervisor_resource_name
    controller_name
  end

  # Because active_admin don't check permissions for custom methods, but I do
  # (collection_action, page_action, member_action)
  def check_permission_again
    action = params[:action].to_sym
    action = :read if action == :index || action == :show
    user = current_admin_user

    if current_admin_user.roles != [:admin_monitoring]
      # For now apply only for monitoring role
      return
    end

    # Build resource from controller and params[:id]
    # Because sometimes we limit via proc, eg open current_admin_user
    subject = supervisor_resource_name.to_sym
    begin
      klass = active_admin_config.resource_class
      subject = if klass && params[:id]
        klass.find_by_id(params[:id]) || klass
      else
        klass
      end
    rescue Object => error
      $stderr.puts error.message
      $stderr.puts error.backtrace
    end

    if !user.can?(action, subject, params)
      Rails.logger.info "Deny access for #{supervisor_resource_name}/#{action} to #{user.class}:#{user.id}"
      # raise ActiveAdmin::AccessDenied(...) # This is supposed way, but I prefer to redirect back
      flash[:error] = "You don't have access to that page"
      redirect_back_or_to "/admin"
      return false
    end
  rescue Object => error
    $stderr.puts error.message
    $stderr.puts error.backtrace
  end

  def inspect
    "<#{self.class.name}:#{object_id} ... >"
  end
end
=end

