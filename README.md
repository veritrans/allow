Allow - permission library
==========================


Usage:

```ruby
# app/models/user.rb
class User < ActiveRecord::Base
  include Allow::Model
  include Allow::Model::ComaStorage

  self.roles_namespace = "Roles::Map::"
  ROLES = ['admin', 'customer_service', 'financial', 'developer', 'operations']
end

User.find(1).roles #=> [:admin]
User.find(1).roles_list #=> [Roles::Map::Admin]

User.find(1).can?(:index, :payments)
```

Define roles:

```ruby

class Roles::Map::Developer < Roles::Map::BaseUser
  reset! # reloading problem

  cant :all

  # 
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