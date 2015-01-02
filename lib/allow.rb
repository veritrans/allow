module Allow
  extend self

  autoload :Model, 'allow/model'
  autoload :Controller, 'allow/controller'
  autoload :ActiveAdmin, 'allow/active_admin'

end

require "allow/role"
require "allow/guest"
require "allow/supervisor"