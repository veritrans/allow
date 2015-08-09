class Allow::ActiveAdmin < ActiveAdmin::AuthorizationAdapter

  def authorized?(action, subject = nil)

    # Force ActiveAdmin::Comment to be :"active_admin/comments"
    if subject == ActiveAdmin::Comment
      if @user.can?(action, :"active_admin/comments")
        return true
      else
        return false
      end
    end

    subject_name = if subject.is_a?(Class) || subject.is_a?(ActiveAdmin::Page)
      supervisor_resource_name.to_sym
    else
      (subject || supervisor_resource_name.to_sym)
    end

    # action => Symbol, :read, :update, :create...
    # subject_name => Record or Symbol
    if @user.can?(action, subject_name) || @user.can?(action, supervisor_resource_name.to_sym)
      true
    else
      supervisor_denied(action, subject_name)
      false
    end
  end

  def supervisor_resource_name
    if resource.controller.respond_to?(:supervisor_resource_name)
      resource.controller.supervisor_resource_name
    else
      resource.controller.controller_name
    end
  end

  def supervisor_denied(action, subject_name)
    Rails.logger.info "Rejected for #{@user.class}:#{@user.id} for #{supervisor_resource_name.to_sym}/#{action}"
  end

  # By including this class, it will check every action in controller,
  # including custom actions defined via `member_action` and `collection_action`
  # usage
  #
  #   controller do
  #     include Allow::ActiveAdmin::CheckAll
  #   end
  #
  module CheckAll
    extend ActiveSupport::Concern

    included do
      before_action :check_permission_again
    end

    def supervisor_resource_name
      controller_name
    end

    # Because active_admin don't check permissions for custom methods, but I do
    # (collection_action, page_action, member_action)
    def check_permission_again
      action = params[:action].to_sym
      action = :read if action == :index || action == :show
      user = current_admin_user

      # Build resource from controller and params[:id]
      # Because sometimes we limit via proc, eg open current_admin_user
      subject = supervisor_resource_name.to_sym
      begin
        if !active_admin_config.is_a?(ActiveAdmin::Page)
          klass = active_admin_config.resource_class
          subject = if klass && params[:id]
            klass.find_by_id(params[:id]) || klass
          else
            klass
          end
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
  end

end
