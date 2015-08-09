ActiveAdmin.register_page "Feedback" do

  content do
    div "Feedback - index"
  end

  page_action :latest do
    render text: "Feedback - latest"
  end

  controller do
    include Allow::ActiveAdmin::CheckAll
  end
end