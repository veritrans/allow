ActiveAdmin.register Dog do

  collection_action :stats do
    render plain: "Dogs Stats"
  end

  collection_action :private_stats do
    authorize! :private_stats
    render plain: "Private Dogs Stats"
  end
end
