Rails.application.routes.draw do
  post "/encode", to: "short_links#encode"
  post "/decode", to: "short_links#decode"
end
