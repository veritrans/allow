Allow - permission library
==========================

[![Build Status](https://travis-ci.org/veritrans/allow.svg?branch=master)](https://travis-ci.org/veritrans/allow)

Library to manage users' permissions. Build in object oriented way, have support for Rails(4.0, 4.1, 4.2), ActiveRecord and ActiveAdmin

Usage:

```ruby
# app/models/user.rb
class User < ActiveRecord::Base
  include Allow::Model
  include Allow::Model::ComaStorage

  self.roles_namespace = "Roles::Portal::"
  ROLES = ['admin', 'customer_service', 'financial', 'developer', 'operations']
end

user = User.find(1)

user.roles = [:admin, :developer] # => save 'admin,developer' in column 'roles'

user.roles # => [:admin, :developer]
user.roles_list # => [Roles::Portal::Admin, Roles::Portal::Developer]

user.has_role?(:admin) # => true
user.remove_role!(:admin)
user.add_role!(:admin)

user.can?(:index, :payments)

User.with_role(:admin) # => AR scope
```

Define roles:

```ruby
class Roles::Manager < Allow::Role
  can :all
  cant :create, :users
end
```

With namespace and inheritance:

```ruby
class Roles::Portal::Developer < Roles::Portal::BaseUser
  reset!

  cant :all

  can :index, :payments
  can :show, :payments

  can :read, :payments # => :read is shortcut for [:show, :index]

  can :manage, :announcements # => allow all REST actions
  can :anything_with, :announcements # => allow everything

  # Custom proc
  can :read, :admin_users do |a, r|
    if r == :admin_users
      false
    else
      self.id == r.id
    end
  end

end

```

Integrate with Rails controller:

```ruby
class ApplicationController < ActionController::Base
  include Allow::Controller

  # Optional
  supervisor_resource :products

  # Optional, allows override current user
  def supervisor_current_user
    current_user
  end

  # Optional, called when supervisor_current_user don't have permission
  def supervisor_access_denied!(options = {})
    if options.present? && options[:user].present?
      user = options[:user]
      Rails.logger.info "User: #{user.id}"
      Rails.logger.info "User roles: #{user.roles}"
      Rails.logger.info "Failed: can? #{options[:action]}, #{options[:resource]}"
    end

    if request.env['REQUEST_PATH'] == root_path
      render file: "#{Rails.root}/public/403.html", :status => :forbidden, layout: false, content_type: 'text/html'
    else
      redirect_to :root, alert: 'You are not authorized to access this page.'#, status: :forbidden
    end
  end

  # Optional
  def supervisor_resource_obj
    Product.find(params[:id])
  end
end
```

Define custom action group:

```ruby
Allow::Supervisor.groups[:create_and_edit] = [:new, :create, :edit, :update]
# default groups
# view:          [:index, :show]
# manage:        [:index, :show, :new, :create, :edit, :update, :destroy]
# anything_with: [ all actions in controller ]
```


Integrate with ActiveAdmin:

```ruby
# config/active_admin.rb
ActiveAdmin.setup do |config|
  config.authorization_adapter = 'Allow::ActiveAdmin'
end
```

For mode details see [active_admin_docs.md](./active_admin_docs.md)
