## ActiveAdmin integration

### Basic setup:

```ruby
# config/active_admin.rb
ActiveAdmin.setup do |config|
  config.authorization_adapter = 'Allow::ActiveAdmin'
end

# app/models/admin_user.rb
class AdminUser < ActiveRecord::Base
  include Allow::Model
  include Allow::Model::ComaStorage

  self.roles_namespace = "Roles::Admin::"

  ROLES = ['super_admin', 'manager', 'developer', 'customer_support', 'finance']
  # ...
end

# app/models/roles/super_admin.rb
class Roles::Admin::Supreme < Roles::Admin::BaseAdminUser
  reset!
  can :all
end

# app/models/roles/manager.rb

class Roles::Admin::Manager < Roles::Admin::BaseAdminUser
  reset!
  can  :all
  cant :manage, :users
  can  :see, :users
end

# app/admin/articles.rb
ActiveAdmin.register Article do
  menu if: proc { current_admin_user.can?(:read, :articles) }
end
```

### Access to ActiveAdmin's comments:

In role defenition
```ruby
can :read, :"active_admin/comments"
```

To control appearance in top menu use

```ruby
ActiveAdmin.setup do |config|
  config.authorization_adapter = 'Allow::ActiveAdmin'
end
```

### Access to custom actions

By default ActiveAdmin check permission only for REST actions (`:index, :show, :new, :create, :edit, :update, :destroy`).
For actions defined via `member_action`, `collection_action` and `page_action` there is 2 solutions:

**Call `authorize! :action_name` in every action**

```ruby
ActiveAdmin.register Dog do
  collection_action :private_stats do
    authorize! :private_stats
    render plain: "Private Dogs Stats"
  end
end
```

**Use `Allow::ActiveAdmin::CheckAll`**

```ruby
ActiveAdmin.register_page "Feedback" do
  controller do
    include Allow::ActiveAdmin::CheckAll
  end
end
```

You also can use `Allow::ActiveAdmin::CheckAll` for every action in ActiveAdmin

```ruby
# config/active_admin.rb
ActiveAdmin::ResourceController.class_eval do
  include Allow::ActiveAdmin::CheckAll
end
```
