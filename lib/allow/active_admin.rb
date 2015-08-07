class Allow::ActiveAdmin < ActiveAdmin::AuthorizationAdapter

  def authorized?(action, subject = nil)

    # In active_admin, to decide show or not show item in top menu
    # we need to check in every resource-related file
    #
    #   menu parent: 'Admin', if: proc{ current_admin_user.can?(:read, :jobs) }
    #
    # Bug for ActiveAdmin::Comment, it defiend in active_admin gem.
    # So we need this hack to controll show or not show "Comments" in top menu
    if subject == ActiveAdmin::Comment
      p [:check, action, :active_admin_comment]
      if @user.can?(action, :active_admin_comment)
        return true
      else
        return false
      end
    end

    if subject.is_a?(ActiveAdmin::Comment)
      p [:check, action, subject]
      if @user.can?(action, subject)
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

    #p [:authorized?, subject, action, subject_name]
    #p [:can?, action, supervisor_resource_name.to_sym]
    # action => Symbol, :read, :update, :create...
    # subject_name => Record or Symbol
    #p [:one, action, subject_name]
    #p [:two, action, supervisor_resource_name.to_sym]
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

end
