# frozen_string_literal: true

require 'travis/sso'
require 'sinatra/base'

class Application < Sinatra::Base
  register Travis::SSO
  get('/') { "Hi, #{user.name}!" }
end

Application.run! if __FILE__ == $PROGRAM_NAME
