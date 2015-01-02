class Allow::ActiveAdmin < ActiveAdmin::AuthorizationAdapter

  def authorized?(action, subject = nil)
    if subject == ActiveAdmin::Comment
      return false
    end

    subject_name = if subject.is_a?(Class) || subject.is_a?(ActiveAdmin::Page)
      supervisor_resource_name.to_sym
    else
      (subject || supervisor_resource_name.to_sym)
    end

    # action => Symbol, :read, :update, :create...
    # subject_name => Record or Symbol
    # p [action, subject_name]
    if @user.can?(action, subject_name) || @user.can?(action, supervisor_resource_name.to_sym)
      true
    else
      Rails.logger.info "Rejected for #{@user.class}:#{@user.id} for #{supervisor_resource_name.to_sym}/#{action}"
      false
    end
  end

  def supervisor_resource_name
    if resource.controller.respond_to?(:supervisor_resource_name)
      resource.controller.supervisor_resource_name
    else
      resource.controller.controller_name#.singularize.classify.constantize
    end
  end

end
