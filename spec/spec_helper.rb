ENV['RACK_ENV'] = ENV['RAILS_ENV'] = ENV['ENV'] = 'test'

require 'rspec'
require 'travis/sso'
require 'sinatra/base'

class Object
  # This little hack makes flexmock largely compatible with rspec-mock and mocha.
  def should_receive(*args, &block)
    example = Thread.current[:example]
    fail "not in any rspec example" unless example
    example.flexmock(self).should_receive(*args, &block)
  end
end

module Helpers
  def stub!(methods = {})
    flexmock(subject, methods)
  end
end

RSpec.configure do |c|
  c.color = true
  c.expect_with :rspec, :stdlib
  c.mock_with :flexmock
  c.include Helpers

  # see Object#should_receive
  c.before(:each) { Thread.current[:example] = self }
  c.after(:each) { Thread.current[:example] = nil }
end
