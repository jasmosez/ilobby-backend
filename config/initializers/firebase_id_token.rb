FirebaseIdToken.configure do |config|
  config.project_ids = ['fir-react-starter-83bea']
  # config.redis = Redis.new(host: '10.0.1.1', port: 6380, db: 15)
  config.redis = Redis.new(url: ENV["REDIS_URL"], ssl_params: { verify_mode: OpenSSL::SSL::VERIFY_NONE })
end
