require 'travis/sso'
require 'sinatra'

configure do |c|
  c.register Travis::SSO
end

get '/' do
  "Hi, #{user.name}!"
end
