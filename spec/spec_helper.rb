ENV['RACK_ENV'] = ENV['RAILS_ENV'] = ENV['ENV'] = 'test'

require 'rspec'
require 'travis/sso'
require 'sinatra/base'

RSpec.configure do |c|
  c.color = true
end
