# Atdis

[![Build Status](https://travis-ci.com/openaustralia/atdis.png?branch=master)](https://travis-ci.com/openaustralia/atdis) [![Coverage Status](https://coveralls.io/repos/openaustralia/atdis/badge.png?branch=master)](https://coveralls.io/r/openaustralia/atdis?branch=master) [![Code Climate](https://codeclimate.com/github/openaustralia/atdis.png)](https://codeclimate.com/github/openaustralia/atdis) [![Gem Version](https://badge.fury.io/rb/atdis.png)](http://badge.fury.io/rb/atdis)

A ruby interface to the application tracking data interchange specification (ATDIS) API

This has been developed against [ATDIS version 1.0.2](https://github.com/openaustralia/atdis/raw/master/docs/ATDIS-1.0.2%20Application%20Tracking%20Data%20Interchange%20Specification%20(v1.0.2).pdf).

Source code is available on GitHub at https://github.com/openaustralia/atdis

## Installation

Add this line to your application's Gemfile:

    gem 'atdis'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install atdis

## Usage

### Basic usage

    require 'atdis'
    f = ATDIS::Feed.new("http://www.planningalerts.org.au/atdis/feed/1/atdis/1.0")

    # Get the first application in the first page of results for all the applications
    page = f.applications
    app = page.response.first

    puts "#{app.dat_id}: #{app.description} at #{app.location.address}"

    DA2013-0381: New pool plus deck at 123 Fourfivesix Street Neutral Bay NSW 2089

### Paging

    page.next_page

and

    page.previous_page

### Validation

    page.valid?

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
