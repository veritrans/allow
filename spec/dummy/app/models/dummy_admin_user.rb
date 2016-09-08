class DummyAdminUser
  include Allow::Model
  cattr_accessor :current

  attr_accessor :roles

  def initialize(*new_roles)
    self.roles = Array.wrap(new_roles)
  end

  def id; roles.try(:join, ","); end

  class Admin < Allow::Role
    can :all
  end

  class Dashboard < Allow::Role
    cant :all
    can :read, :dashboard
    can :read, :feedback
  end

  class Commentor < Allow::Role
    cant :all
    can :read, :"active_admin/comments"
    can :read, :dogs
  end

  class Dogger < Allow::Role
    cant :all
    can :read, :dogs
    can :private_stats, :dogs
  end

  class Manager < Allow::Role
    cant :all
    can :read, :feedback
  end

  class FeedbackManager < Allow::Role
    cant :all
    can :anything_with, :feedback
  end

  self.roles_namespace = "DummyAdminUser::"
end
