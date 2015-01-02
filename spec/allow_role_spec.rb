require "spec_helper"

module RoleTest
  class User
    include Allow::Model

    attr_accessor :roles
    attr_accessor :email

    def initialize(roles = [])
      if roles.is_a?(Hash)
        roles.each do |key, value|
          send(:"#{key}=", value)
        end
      else
        @roles = roles
      end
    end
  end

  class Bank
  end

  class Merchant
  end
end

module Roles
  class TestRole1 < Allow::Role
  end

  class TestRole2 < Allow::Role
  end

  class User < Allow::Role
  end

  class Admin < Allow::Role
    can :all
  end
end

describe Allow do
  before :all do
    @user = RoleTest::User.new
  end

  before(:each) do
    Roles::TestRole1.reset!.allow(:all)
    Roles::TestRole2.reset!.allow(:all)
  end

  it "should have 2 roles constantinized" do
    @user.roles = [:user, :admin]
    @user.roles_list.should include(Roles::User)
    @user.roles_list.should include(Roles::Admin)
  end

  it "should have method #can?" do
    @user.roles = [:user, :admin]
    @user.respond_to?(:can?).should be_true
  end

  describe "Role" do

    it "should have permissions" do
      Roles::TestRole1.permissions.size.should == 1
      Roles::TestRole1.challenge_permission(@user, :do, :something, Roles::TestRole1.permissions.first).should be_true
      Roles::TestRole1.allowed?(@user, :do, :something).should be_true
    end

    it "should challenge permission" do
      Roles::TestRole1.class_eval do
        cant :watch, :tv
      end

      Roles::TestRole1.allowed?(@user, :watch, :tv).should == false
    end

    it "should check :if option" do
      spy = false
      Roles::TestRole1.can :watch, :tv, if: lambda {|*a|
        # Time.now.hour > 8
        spy = true
        false
      }

      Roles::TestRole1.allowed?(@user, :watch, :tv).should == false
      spy.should == true
    end

    it "should accept block as :if option" do
      spy = false
      Roles::TestRole1.can(:watch, :tv) do |resource, action|
        # Time.now.hour > 8
        spy = true
        false
      end

      Roles::TestRole1.allowed?(@user, :watch, :tv).should == false
      spy.should == true
    end

    it "should negative :if" do
      spy = false
      Roles::TestRole1.cant(:watch, :tv) do |*a|
        # Time.now.hour > 8
        spy = true
        false
      end

      Roles::TestRole1.allowed?(@user, :watch, :tv).should == true
    end

    it "should pass object to :if block and works with aliases" do
      user = false
      spy = false
      resource = false
      action = false

      Roles::TestRole1.can(:anything_with, :users) do |a, r|
        resource  = r
        action    = a
        user      = self
        spy       = true

        false
      end

      new_user = RoleTest::User.new(email: "Test")

      Roles::TestRole1.allowed?(@user, :pinch, new_user).should == false
      spy.should == true
      user.should == @user
      resource.email.should == new_user.email
      action.should == :pinch
    end

    it "should work with groups and macros" do
      Roles::TestRole1.cant(:anything_with, :books)
      Roles::TestRole1.can(:manage, :books)

      Roles::TestRole1.allowed?(@user, :something, :books).should == false
      Roles::TestRole1.allowed?(@user, :manage, :books).should == true
      Roles::TestRole1.allowed?(@user, :create, :books).should == true
      Roles::TestRole1.allowed?(@user, :destroy, :books).should == true
    end

    it "should respect order" do
      Roles::TestRole1.class_eval do
        can :go_out, :tonight
        cant :go_out, :tonight
        can :go_out, :tonight
        cant :go_out, :tonight
        can :go_out, :tonight
        cant :go_out, :tonight
        can :go_out, :tonight
        # thats how I arrange date with my gf

        cant :go_out, :tonight
      end

      Roles::TestRole1.allowed?(@user, :go_out, :tonight).should == false
    end

    it "should works with AR objects" do
      Roles::TestRole1.class_eval do
        cant :all
        can :manage, :"role_test/banks"
        cant :destroy, :"role_test/banks"
      end

      @user.roles = [:test_role1]
      bank = RoleTest::Bank.new

      @user.can?(:edit, bank).should be_true
      @user.can?(:destroy, bank).should be_false
      @user.can?(:create, RoleTest::Merchant.new).should be_false # test "cant :all"
      @user.can?(:invent, nil).should be_false
    end
  end

  #require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

  describe "Sepervisor" do
    it "should allowed if any role allows" do
      Roles::TestRole1.cant(:anything_with, :books)
      Roles::TestRole2.cant(:all)
      Roles::TestRole2.can(:manage, :books)

      @user.roles = [:test_role1, :test_role2]
      @user.can?(:edit, :books).should == true
      @user.can?(:view, :books).should == false
    end
  end

  Roles::TestRole3.reset! if defined?(Roles::TestRole3)
  Roles::TestRole4.reset! if defined?(Roles::TestRole4)

  class Roles::TestRole3 < Allow::Role
    can :all
  end

  class Roles::TestRole4 < Roles::TestRole3
    cant :all
  end

  it "should have right permissions" do
    Roles::TestRole3.permissions.size.should == 1
    Roles::TestRole4.permissions.size.should == 2
  end
end

