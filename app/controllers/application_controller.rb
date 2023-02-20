class ApplicationController < ActionController::API
  include ActionController::Cookies
  config.action_dispatch.cookies_same_site_protection = :none
end
