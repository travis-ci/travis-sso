require 'travis/sso'
require 'sinatra'

secrets = {}
use Travis::SSO, mode: :single_page,
  get_otp_secret: -> user { secrets[user['login']] },
  set_otp_secret: -> user, secret { secrets[user['login']] = secret }

get '/' do
  "You made it!"
end
