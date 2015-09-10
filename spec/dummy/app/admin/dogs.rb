ActiveAdmin.register Dog do
  collection_action :stats do
    render text: "Dogs Stats"
  end

  collection_action :private_stats do
    authorize! :private_stats
    render text: "Private Dogs Stats"
  end
end
