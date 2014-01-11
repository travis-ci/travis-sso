require 'travis/sso'
require 'sinatra'

secrets = {}

configure do |c|
  c.register Travis::SSO
end

get '/' do
  "Hi, #{user.name}!"
end
