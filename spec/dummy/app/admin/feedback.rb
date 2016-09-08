ActiveAdmin.register_page "Feedback" do

  content do
    div "Feedback - index"
  end

  page_action :latest do
    render plain: "Feedback - latest"
  end

  controller do
    include Allow::ActiveAdmin::CheckAll
  end
end
