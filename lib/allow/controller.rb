module Allow::Controller
  extend ActiveSupport::Concern

  included do
    before_filter :check_permission
  end

  module ClassMethods
    # supervisor_resource :user
    # supervisor_resource "Merchant::Log"
    def supervisor_resource(resource_name = nil)
      if resource_name
        @supervisor_resource_name = resource_name
      end
      @supervisor_resource_name
    end

    # supervisor :skip
    # supervisor :only => [:create, :destroy]
    # supervisor :except => [:index]

    def supervisor(options)

    end
  end

  # For overwrides
  def supervisor_current_user
    current_user
  end

  def check_permission
    user = supervisor_current_user || Allow::Guest.new
    resource_arg = supervisor_resource_obj || supervisor_resource_name.to_sym
    result = Allow::Supervisor.check_permission(user, params[:action].to_sym, resource_arg, params)

    #p [user.roles, params[:action].to_sym, supervisor_resource_name.to_sym, result]

    if result === false
      Rails.logger.info "User #{user.id} - #{user.roles_list} not allowed to #{supervisor_resource_name}##{params[:action]} "
      supervisor_access_denied!(user: user, action: params[:action].to_sym, resource: supervisor_resource_name.to_sym)
    end
    return result
  end

  # To be easy customizable
  def supervisor_access_denied!(options = {})
    render file: "#{Rails.root}/public/403.html", :status => :forbidden, layout: false, content_type: 'text/html'
  end

  def supervisor_resource_name
    if resource_name = self.class.supervisor_resource
      resource_name.is_a?(Class) ? resource_name.to_s.camelize.to_s : resource_name.to_s#.classify.constantize
    elsif respond_to?(:resource_name) && resource_name.present?
      resource_name
    else
      controller_name#.singularize.classify.constantize
    end
  end

  def supervisor_resource_obj
    klass = supervisor_resource_name.classify.constantize
    if klass < ActiveRecord::Base && params[:id]
      return klass.find(params[:id])
    end
  rescue ActiveRecord::RecordNotFound => error
    Rails.logger.info "Can't find '#{klass.name} with id = #{params[:id]}"
    nil
  rescue NameError => error
    nil
  end
end
