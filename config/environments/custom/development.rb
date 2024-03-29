Rails.application.configure do
  # Overwrite settings for the development environment or add your own
  # custom settings for this environment.
  config.anonymous_credentials = '123456789123456'

  config.viisp_pid = 'VSID000000000113'
  config.viisp_key_route = './config/keys/testKey.pem'
  config.base_url = 'http://212.24.109.28:3000'
  config.viisp_test = true

  config.krs_endpoint = 'http://195.182.94.66:8888'
end
