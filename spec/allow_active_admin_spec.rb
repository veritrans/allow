require "spec_helper"

load_dummy_rails_app

ActiveAdmin::Comment.skip_callback(:create, :before, :set_resource_type)

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
  end

  def create_comment
    comment = ActiveAdmin::Comment.new(
      namespace: "admin", body: "bbb", author_id: 1, author_type: 'ActiveAdmin::Comment',
      resource_id: 1, resource_type: 'ActiveAdmin::Comment'
    )
    comment.save!(validate: false)
    comment
  end

  context "access ActiveAdmin's Comments" do
    it "allow for user with full access" do
      should_be_accessable('/admin', "Admin::DashboardController#index")
      should_be_accessable('/admin/comments', "Admin::CommentsController#index")
    end

    it "reject :index for user with 'cant :active_admin_comment'" do
      DummyAdminUser.current.roles = [:dashboard]
      should_be_accessable('/admin', "Admin::DashboardController#index")
      should_be_rejected('/admin/comments')
    end

    it "reject :show" do
      DummyAdminUser.current.roles = [:dashboard]
      comment = create_comment
      should_be_rejected('/admin/comments')
      should_be_rejected("/admin/comments/#{comment.id}")
    end

    it "allow :index and :show for user with :active_admin_comment" do
      DummyAdminUser.current.roles = [:commentor]
      comment = create_comment
      should_be_rejected('/admin')
      should_be_accessable('/admin/comments')
      should_be_accessable("/admin/comments/#{comment.id}", "Admin::CommentsController#show")
    end
  end

  context "access to resource" do
    it "should allow for :index and :show" do
      DummyAdminUser.current.roles = [:commentor]
      dog = Dog.create(name: "Bobik")
      should_be_rejected('/admin')
      should_be_accessable('/admin/dogs')
      should_be_accessable("/admin/dogs/#{dog.id}", "Admin::DogsController#show")
    end

    it 'should not check custom actions' do
      DummyAdminUser.current.roles = [:commentor]
      should_be_accessable('/admin/dogs')
      should_be_accessable("/admin/dogs/stats", "Dogs Stats")
      should_be_rejected("/admin/dogs/private_stats")
    end

    it "should work with 'authorize!'" do
      DummyAdminUser.current.roles = [:dogger]
      should_be_accessable('/admin/dogs')
      should_be_accessable("/admin/dogs/stats", "Dogs Stats")
      should_be_accessable("/admin/dogs/private_stats", "Private Dogs Stats")
    end
  end

  context "Allow::ActiveAdmin::CheckAll" do
    it "should check access for page_action" do
      DummyAdminUser.current.roles = [:manager]
      should_be_rejected('/admin')
      should_be_accessable('/admin/feedback')
      should_be_rejected('/admin/feedback/latest')
    end

    it "should check access for page_action" do
      DummyAdminUser.current.roles = [:feedback_manager]
      should_be_rejected('/admin')
      should_be_accessable('/admin/feedback')
      should_be_accessable('/admin/feedback/latest')
    end
  end
end