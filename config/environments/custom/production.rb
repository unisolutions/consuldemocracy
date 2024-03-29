Rails.application.configure do
  # Overwrite settings for the production environment or add your own
  # custom settings for this environment.
  #Anonymous data
  config.anonymous_credentials = '123456789123456'
  #
  #VIISP credentials
  config.viisp_pid = 'VSID000000005850'
  config.viisp_key_route = './config/keys/dalyvauk-private.pem'
  config.base_url = 'https://dalyvauk.krs.lt'
  config.viisp_test = false

  config.krs_endpoint = 'http://192.168.201.90/wp-json/krsapi/v1'


end
