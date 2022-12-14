Rails.application.routes.draw do

  KeyVisual::Initializer

  concern :deletion do
    get :delete, on: :member
    delete :destroy_all, on: :collection, path: ''
  end

  content "key_visual" do
    get "/" => redirect { |p, req| "#{req.path}/images" }, as: :main
    resources :images, concerns: :deletion
  end

  node "key_visual" do
    get "image/" => "public#index", cell: "nodes/image"
  end

  part "key_visual" do
    get "slide" => "public#index", cell: "parts/slide"
    get "swiper_slide" => "public#index", cell: "parts/swiper_slide"
  end

  page "key_visual" do
    get "image/:filename.:format" => "public#index", cell: "pages/image"
  end

end
