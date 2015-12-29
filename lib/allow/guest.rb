class Allow::Guest
  include Allow::Model

  def roles
    [:guest]
  end
end

module Roles
  class Guest < Allow::Role
    can :all
  end
end

