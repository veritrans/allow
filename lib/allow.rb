require 'logger'

module Allow
  extend self

  autoload :Model, 'allow/model'
  autoload :Controller, 'allow/controller'
  autoload :ActiveAdmin, 'allow/active_admin'

  def logger
    @logger ||= Logger.new("/dev/null")
  end

  def logger=(value)
    @logger = value
  end

end

require "allow/role"
require "allow/guest"
require "allow/supervisor"