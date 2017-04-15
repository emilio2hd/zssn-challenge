Apipie.configure do |config|
  config.app_name                = 'Zssn'
  config.api_base_url            = '/'
  config.doc_base_url            = '/doc'
  config.validate                = false
  config.default_version         = 'v1'
  # where is your API defined?
  config.api_controllers_matcher = File.join(Rails.root, 'app', 'controllers', '**', '*.rb')

  config.api_base_url['v1'] = '/v1'
  config.app_info['v1'] = 'Zombie Survival Social Network'
end
