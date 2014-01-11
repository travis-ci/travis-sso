require 'travis/sso'
require 'sinatra'

secrets = {}

configure do |c|
  c.set :sso, # two factor auth
    get_otp_secret: -> u   { secrets[u['login']]     },
    set_otp_secret: -> u,s { secrets[u['login']] = s }
  c.register Travis::SSO
end

get '/' do
  "Hi, #{user.name}!"
end
