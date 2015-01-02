module Allow
  extend self

  autoload :Model, 'allow/model'
  autoload :Controller, 'allow/controller'

end

require "allow/role"
require "allow/guest"
require "allow/supervisor"