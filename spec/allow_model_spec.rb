require 'active_record'

ActiveRecord::Base.configurations['test'] = {adapter: "sqlite3", database: ":memory:", verbosity: 'quiet'}
#ActiveRecord::Base.logger = Logger.new(STDOUT)

module ModelTest
  class User < ActiveRecord::Base
    establish_connection :test
    include Allow::Model
    include Allow::Model::ComaStorage

    self.roles_namespace = "ModelTest::"
    ROLES = ['admin', 'customer_service', 'financial', 'developer', 'operations']
  end

  User.connection.create_table User.table_name do |t|
    t.string  "email"
    t.string  "roles"
    t.string  "merchant_id"

    t.timestamps null: false
  end

  class TestRole1 < Allow::Role
    can :anything_with, :something
  end

  class Admin < Allow::Role
    can :all
  end
end

describe "User" do
  # It not suppose to work with sqlite3, but it does
  before :all do
    connection = ModelTest::User.connection.instance_variable_get(:@connection)
    connection.create_function('regexp', 2) do |func, pattern, expression|
      func.result = expression.to_s.match(Regexp.new(pattern.to_s, Regexp::IGNORECASE)) ? 1 : 0
    end
  end

  before do
    @user = ModelTest::User.create
  end

  it "should have permission for everything" do
    @user.roles = [:test_role1]
    @user.can?(:whatever_with, :something).should be_true
  end

  it "should allow admin login #fix bug" do
    @user.roles = [:admin]
    @user.can?(:create, :sessions).should be_true
  end

  it "should make search by role" do
    other_user = ModelTest::User.create(roles: [:admin_user, :user_blabla])
    @user.roles = [:user]
    @user.save

    users = ModelTest::User.with_role(:user).to_a
    users.size.should == 1
    users.should include(@user)
    users.should_not include(other_user)
  end
end
