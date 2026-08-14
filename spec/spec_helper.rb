# frozen_string_literal: true

require "simplecov"

SimpleCov.start do
  add_filter "/spec/"
  enable_coverage :branch
end

require "rubygems"
require "bundler/setup"

require "atdis" # and any other gems you need

RSpec.configure do |config|
  # some (optional) config here
end
