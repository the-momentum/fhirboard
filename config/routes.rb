# frozen_string_literal: true

Rails.application.routes.draw do
  mount Helth.app => "/up"

  resources :view_definitions do
    get :generate_query
    post :run_query
    get :save_to_superset
  end

  resources :analyses do
    get :export_to_superset
    get :save_as_views
  end

  # Render dynamic PWA files from app/views/pwa/*
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  root "static_pages#index"
end
