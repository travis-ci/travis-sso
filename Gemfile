# frozen_string_literal: true

source 'https://rubygems.org'
gemspec

group :development do
  gem 'rake'
  gem 'sinatra'
end

group :test do
  gem 'rspec'
end

group :development, :test do
  gem 'rubocop', require: false
  gem 'rubocop-performance', require: false
  gem 'rubocop-rspec', require: false
  gem 'simplecov', require: false
  gem 'simplecov-console', require: false
end
