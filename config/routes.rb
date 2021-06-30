Rails.application.routes.draw do
  resources :messages
  resources :conversations
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
  root 'pages#userlanding'
  get 'pages/about'
  get 'pages/innovation'
  get 'pages/help'
  get 'pages/success'
  get 'pages/terms'
  devise_for :users,
    path: '',
    path_name: {sign_in: 'login', sign_out: 'logout', edit: 'profile', sign_up: 'registration'},
    controllers: {registration: 'registration'}
  
  resources :users, only: [:index, :show]

  resource :contact_tables, only: [:create]

  resources :posts, param: :slug, only: [:index, :show, :create, :destroy] do
     resources :photos, only: [:create]
     resources :likes, only: [:create, :destroy], shallow: true
     resources :comments, only: [:index, :create, :destroy], shallow: true
     resources :bookmarks, only: [:create, :destroy], shallow: true
  end

  #custom route defined
  get 'pages/contact_get'
  post 'pages/contact_get/:id', :to => 'pages#contact_get'
  get 'post/module_post', :to => 'posts#module_post', as: 'module'
  get 'posts/build_module/:slug', :to => 'posts#build_module', as: 'building'
end