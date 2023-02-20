Rails.application.config.session_store :cookie_store, key: "_session_id", secure: true, same_site: :none if Rails.env.production?
