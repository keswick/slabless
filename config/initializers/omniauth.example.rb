Rails.application.config.middleware.use OmniAuth::Builder do
  provider :facebook, 'app_id', 'app_secret'
end