require 'simplecov'
require 'coveralls'

# Generate coverage locally in html as well as in coveralls.io
SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter.new([
  SimpleCov::Formatter::HTMLFormatter,
  Coveralls::SimpleCov::Formatter
])
SimpleCov.start

require 'rubygems'
require 'bundler/setup'

require 'atdis' # and any other gems you need

RSpec.configure do |config|
  # some (optional) config here
end
