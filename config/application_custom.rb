module Consul
  class Application < Rails::Application
    config.time_zone = "Vilnius"
    config.i18n.available_locales = [:lt, :en]
    config.i18n.default_locale = :lt

    config.action_dispatch.default_headers = {
      'Referrer-Policy' => 'same-origin'
    }
    config.action_controller.forgery_protection_origin_check = false

  end
end
