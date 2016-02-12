Rails.application.routes.draw do
  root 'nodes#index', as: "nodes"

  match "login" => 'sessions#new', as: "login", via: %i{get post}
  get 'logout' => 'sessions#destroy', as: "logout"
  get 'stats' => 'stats#index', as: "stats"

  constraints(hostname: /[^\/]+/) do
    resources :nodes, param: :hostname do
      collection do
        post :register
      end
      member do
        post :comment
        post :tag
      end
    end
  end

  get 'upgrades' => 'packages#index', as: "upgrades"
  post 'package/update_status' => 'packages#update_status', as: "package_nodes_update_status"
  get 'package/:id' => 'packages#show', as: "package"
  get 'package/:id/nodes' => 'packages#nodes', as: "package_nodes"
  post 'package/:id/nodes' => 'packages#apply'

  get "action/:id/output" => 'actions#output', as: "action_output"
  get "action/:id" => 'actions#show', as: "action"
  get "actions" => 'actions#index', as: "actions"

  resources :scripts do
    member do
      get "download" => 'scripts#download'
      post "execute" => 'scripts#execute'
    end
  end

  resources :users
end
