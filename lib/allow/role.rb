class Allow::Role
  @@aliases = {
    all: lambda {|*a| true },
    anything_with: lambda {|permission, action, resource, controller_params = nil|
      permission[2] == resource ? true : nil
    }
  }

  #@@permissions = []

  def self.can(action, resource = nil, options ={}, &block)
    if resource.is_a?(Hash)
      options = resource
      resource = nil
    end

    options[:if] = block if block_given?
    add_permission([:can] + [action, resource, options])
  end

  def self.allow(*args, &block)
    can(*args, &block)
  end

  def self.cant(action, resource = nil, options ={}, &block)
    if resource.is_a?(Hash)
      options = resource
      resource = nil
    end

    options[:if] = block if block_given?
    add_permission([:cant] + [action, resource, options])
  end

  def self.deny(*args, &block)
    cant(*args, &block)
  end

  # ====================

  def self.allowed?(user, action, resource = nil, controller_params = nil)
    result = false
    last_affected_pemission = nil
    permissions.each do |perm|
      v = challenge_permission(user, action, resource, perm, controller_params)
      result = v if v === true or v === false
      # for debug
      last_affected_pemission = perm if v === true or v === false
    end

    #puts "Final on #{last_affected_pemission} #{challenge_permission(user, action, resource, last_affected_pemission)}"
    result
  end

  def self.challenge_permission(user, action, resource_obj, permission, controller_params = nil)
    resource = normalize_resource_name(resource_obj)

    short = permission[1] # if permission[2].nil?
    permission_action = permission[1]
    permission_resource = permission[2]
    permission_options = permission[3]

    result = nil

    if permission_resource.nil? && !@@aliases[short]
      raise ArgumentError, "unknown short permisson #{short}"
    end

    if aliased = @@aliases[short]
      if !permission_options[:if] || allowed_by_if_option?(permission_options, user, resource_obj, action, controller_params)
        if aliased.is_a?(Proc)
          user.instance_eval do
            v = aliased.call(permission, action, resource, controller_params)
            result = v if v === true || v === false
          end
        else
          result = aliased if aliased === true || aliased === false
        end # /if aliased.is_a?(Proc)
      else
        result = false
      end
    else
      # group of actions for current permission
      # can be [:manage, :new, :create, :edit, ...]
      permission_actions = [permission_action]
      if Allow::Supervisor.groups[permission_action]
        permission_actions += Allow::Supervisor.groups[permission_action]
      end

      if permission_actions.include?(action.to_sym) && resource.to_sym == permission_resource
        result = true
        if result && permission_options[:if]
          result = allowed_by_if_option?(permission_options, user, resource_obj, action, controller_params)
        end
      end
    end

    if result.nil?
      return nil
    else
      permission[0] == :can ? result : !result
    end
  end

  def self.allowed_by_if_option?(permission_options, user, resource_obj, action, controller_params)
    user.instance_exec(action, resource_obj, controller_params, &permission_options[:if])
  end

  # convert ar-record or any object to string
  def self.normalize_resource_name(resource)
    if resource.is_a?(String)
      resource = resource.to_sym
    end

    if !resource.is_a?(Symbol)
      klass = resource.is_a?(Class) || resource.is_a?(Module) ? resource : resource.class
      resource = klass.to_s.underscore.pluralize.to_sym
    end
    resource
  end

  def self.add_permission(perm)
    self.own_permissions.push(perm)
  end

  def self.own_permissions
    @permissions ||= []
    @permissions
  end

  def self.permissions
    (superclass < Allow::Role ? superclass.permissions : []) + own_permissions
  end

  def self.reset!
    @permissions.clear if @permissions
    self
  end
end
