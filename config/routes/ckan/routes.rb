Rails.application.routes.draw do

  Ckan::Initializer

  concern :deletion do
    get :delete, on: :member
  end

  content "ckan" do
    get "/" => redirect { |p, req| "#{req.path}/pages" }, as: :main
    resources :pages, only: [:index]
  end

  node "ckan" do
    get "page/(index.:format)" => "public#index", cell: "nodes/page"
    get "page/rss" => "public#rss", cell: "nodes/page"
  end

  part "ckan" do
    get "status" => "public#index", cell: "parts/status"
    get "page" => "public#index", cell: "parts/page"
    get "reference" => "public#index", cell: "parts/reference"
  end
end
