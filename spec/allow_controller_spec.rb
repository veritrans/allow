require "spec_helper"

require 'action_controller'
require 'action_view'
require 'active_record'

require 'rspec/rails'

module Roles; end

module ControllerTest
  class Application < Rails::Application
    config.secret_key_base = "1111"
  end

  class User
    include Allow::Model
    attr_accessor :roles

    def initialize(roles = [])
      @roles = roles
    end

    def id
      object_id
    end
  end
  
end

# ==== SAMPLE DATA

Roles::AllowTestingRole.reset! if defined?(Roles::AllowTestingRole)

class Roles::AllowTestingRole < Allow::Role
  @@last_challange = []
  @@challanges = []
  cattr_accessor :last_challange, :challanges


  def self.allowed?(user, action, resource = nil, controller_params = nil)
    @@challanges << [user, action, resource]
    @@last_challange = [user, action, resource]
    super(user, action, resource, controller_params)
  end

  can :all
  cant :new, :allow_testings
end

"#{ActionController::Base}"

class AllowTestingsController < ActionController::Base
  include Allow::Controller
  include Rails.application.routes.url_helpers

  def new
    render plain: "new", layout: false
  end

  def index
    render plain: "index", layout: false
  end

  def supervisor_access_denied!(options = {})
    render plain: "supervisor_access_denied!", status: 403
  end
end

# ===== END SAMPLE DATA

describe AllowTestingsController, :type => :controller do
  include RSpec::Rails::ControllerExampleGroup

  before :all do
    @current_user = ControllerTest::User.new([:allow_testing_role])

    Rails.application.routes.draw do
      get 'allow_testings'      => 'allow_testings#index', as: :allow_testings
      get 'allow_testings/new'  => 'allow_testings#new',   as: :new_allow_testings
    end
  end

  after :all do
    Rails.application.reload_routes!
  end

  before :each do
    Roles::AllowTestingRole.last_challange = []
    Roles::AllowTestingRole.challanges = []

    user = @current_user
    AllowTestingsController.any_instance.stub(current_user: user)
  end

  it "should check permissions of current_user" do
    get :index

    Roles::AllowTestingRole.challanges.size.should == 1
    Roles::AllowTestingRole.last_challange.should == [@current_user, :index, :allow_testings]
    response.status.should == 200
  end

  it "should forbidden page on forbidden action" do
    get :new

    response.status.should == 403
    response.body.should == "supervisor_access_denied!"
  end
end