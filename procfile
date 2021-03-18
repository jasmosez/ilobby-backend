web: bundle exec puma -C config/puma.rb
worker: rails firebase:certificates:force_request
worker: whenever --update-crontab