RailsApp::Application.routes.draw do
  #devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)

  match 'destroy_admin_user_session' => redirect('/admin'), via: [:get]
end