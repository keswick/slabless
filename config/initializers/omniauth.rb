Rails.application.config.middleware.use OmniAuth::Builder do
  provider :facebook, '209041935879507', '62cf580ac77c6c897dfc3d8468fc4b7b'
end