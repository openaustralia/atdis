# ATDIS

[![CI](https://github.com/openaustralia/atdis/actions/workflows/ci.yml/badge.svg)](https://github.com/openaustralia/atdis/actions/workflows/ci.yml) [![Gem Version](https://badge.fury.io/rb/atdis.svg)](https://badge.fury.io/rb/atdis)

A Ruby interface for reading and validating planning application data feeds that
follow the Application Tracking Data Interchange Specification (ATDIS).

This has been developed against [ATDIS version 1.0.2](https://github.com/openaustralia/atdis/raw/main/docs/ATDIS-1.0.2%20Application%20Tracking%20Data%20Interchange%20Specification%20(v1.0.2).pdf).

Source code is available on GitHub at https://github.com/openaustralia/atdis

## Requirements

Ruby 3.2 or later.

## Installation

Add this line to your application's Gemfile:

```ruby
gem "atdis"
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install atdis

## Usage

### Basic usage

```ruby
require "atdis"

f = ATDIS::Feed.new("http://www.planningalerts.org.au/atdis/feed/1/atdis/1.0", "Sydney")

# Get the first application in the first page of results for all the applications
page = f.applications
app = page.response.first

puts "#{app.application.info.dat_id}: #{app.application.info.description}"
```

    DA2013-0381: New pool plus deck

### Paging

```ruby
page.next_page
```

and

```ruby
page.previous_page
```

### Validation

```ruby
page.valid?
```

## Development

After checking out the repo, run `bundle install` to install dependencies.
Then run the tests with:

    $ bundle exec rspec

There is also RuboCop for linting:

    $ bundle exec rubocop

## Contributing

Contributions are welcome! This project follows the
[OpenAustralia Foundation contributing guidelines](https://github.com/openaustralia/.github/blob/main/.github/CONTRIBUTING.md).

1. Fork it
2. Create your feature branch (`git checkout -b feature/my-new-feature`)
3. Commit your changes with a sign-off (`git commit -s -am 'Add some feature'`)
4. Push to the branch (`git push origin feature/my-new-feature`)
5. Create new Pull Request

## License

The gem is available as open source under the terms of the
[MIT License](https://github.com/openaustralia/atdis/blob/main/LICENSE.txt).
