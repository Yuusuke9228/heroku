Rails.application.routes.draw do

  Opendata::Initializer

  concern :deletion do
    get :delete, on: :member
    delete :destroy_all, on: :collection, path: ''
  end

  concern :workflow do
    post :request_update, on: :member
    post :approve_update, on: :member
    post :remand_update, on: :member
    get :approver_setting, on: :member
    post :approver_setting, on: :member
    get :wizard, on: :member
    post :wizard, on: :member
  end

  content "opendata" do
    get "/" => "main#index", as: :main
    resources :categories, only: [:index]
    resources :estat_categories, only: [:index]
    resources :areas, only: [:index]

    resources :licenses, concerns: :deletion

    resources :sparqls, only: [:index]
    resources :apis, only: [:index]
    resources :members, only: [:index]

    namespace "workflow" do
      resources :idea_comments, concerns: :workflow
    end
  end

  node "opendata" do
    get "category/" => "public#index", cell: "nodes/category"
    get "estat_category/" => "public#index", cell: "nodes/estat_category"
    get "area/" => "public#index", cell: "nodes/area"

    get "sparql/(*path)" => "public#index", cell: "nodes/sparql"
    post "sparql/(*path)" => "public#index", cell: "nodes/sparql"
    get "api/package_list" => "public#package_list", cell: "nodes/api"
    get "api/group_list" => "public#group_list", cell: "nodes/api"
    get "api/tag_list" => "public#tag_list", cell: "nodes/api"
    get "api/package_show" => "public#package_show", cell: "nodes/api"
    get "api/tag_show" => "public#tag_show", cell: "nodes/api"
    get "api/group_show" => "public#group_show", cell: "nodes/api"
    get "api/package_search" => "public#package_search", cell: "nodes/api"
    get "api/resource_search" => "public#resource_search", cell: "nodes/api"
    get "api/1/package_list" => "public#package_list", cell: "nodes/api"
    get "api/1/group_list" => "public#group_list", cell: "nodes/api"
    get "api/1/tag_list" => "public#tag_list", cell: "nodes/api"
    get "api/1/package_show" => "public#package_show", cell: "nodes/api"
    get "api/1/tag_show" => "public#tag_show", cell: "nodes/api"
    get "api/1/group_show" => "public#group_show", cell: "nodes/api"
    get "api/1/package_search" => "public#package_search", cell: "nodes/api"
    get "api/1/resource_search" => "public#resource_search", cell: "nodes/api"

    # get "member/" => "public#index", cell: "nodes/member"
    get "member/:member" => "public#show", cell: "nodes/member"
    get "member/:member/datasets/(:filename.:format)" => "public#datasets", cell: "nodes/member"
    get "member/:member/apps/(:filename.:format)" => "public#apps", cell: "nodes/member"
    get "member/:member/ideas/(:filename.:format)" => "public#ideas", cell: "nodes/member"
  end

  namespace "opendata", path: ".s:site/opendata" do
    namespace "apis" do
      get "categories" => "categories#index"
      get "estat_categories" => "estat_categories#index"
      get "areas" => "areas#index"
    end
  end
end
