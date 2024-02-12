Rails.application.configure do
  # Overwrite settings for the production environment or add your own
  # custom settings for this environment.

  #Anonymous data
  config.anonymous_credentials = 'X1X2X3X4X5X6X78X'

  #VIISP credentials
  config.viisp_pid = 'VSID000000005850'
  config.viisp_key_route = './config/keys/dalyvauk-private.pem'
  config.base_url = 'https://dalyvauk.krs.lt'
  config.viisp_test = false

end
