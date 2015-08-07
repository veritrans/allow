require "spec_helper"

class DummyAdminUser
  include Allow::Model
  cattr_accessor :current

  attr_accessor :roles

  def initialize(*new_roles)
    self.roles = Array.wrap(new_roles)
  end

  class Admin < Allow::Role
    can :all
  end

  class Dashboard < Allow::Role
    cant :all
    can :read, :dashboard
  end

  class Comments < Allow::Role
    cant :all
    can :read, :active_admin_comment
  end

  self.roles_namespace = "DummyAdminUser::"
end

load_dummy_rails_app

describe Allow::ActiveAdmin, integration: true do
  include Rack::Test::Methods

  def app
    Rails.application
  end

  before do
    DummyAdminUser.current = DummyAdminUser.new(:admin)
  end

  def should_be_accessable(path, content = nil)
    get path
    last_response.status.should == 200
    if content
      last_response.body.should == content
    end
  end

  def should_be_rejected(path)
    get path
    last_response.status.should == 302
    p last_response
  end

  it "allow for user with full access" do
    should_be_accessable('/admin', "Admin::DashboardController#index")
    should_be_accessable('/admin/comments', "Admin::CommentsController#index")
  end

  it "sh" do
    DummyAdminUser.current.roles = [:dashboard]
    should_be_accessable('/admin', "Admin::DashboardController#index")
    should_be_rejected('/admin/comments')
  end
end