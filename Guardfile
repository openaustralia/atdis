# frozen_string_literal: true

# More info at https://github.com/guard/guard#readme

guard "rspec" do
  watch(%r{^lib/(.+)\.rb$}) { |m| "spec/#{m[1]}_spec.rb" }
  watch(%r{^spec/.+_spec\.rb$})
end
