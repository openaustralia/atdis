# Atdis

[![Build Status](https://travis-ci.org/openaustralia/atdis.png?branch=master)](https://travis-ci.org/openaustralia/atdis) [![Coverage Status](https://coveralls.io/repos/openaustralia/atdis/badge.png?branch=master)](https://coveralls.io/r/openaustralia/atdis?branch=master) [![Code Climate](https://codeclimate.com/github/openaustralia/atdis.png)](https://codeclimate.com/github/openaustralia/atdis) [![Gem Version](https://badge.fury.io/rb/atdis.png)](http://badge.fury.io/rb/atdis)

A ruby interface to the application tracking data interchange specification (ATDIS) API

We're developing this against version ATDIS 1.0.7.

This is **beta** software and is a work in progress.

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
    f = ATDIS::Feed.new("http://www.planningalerts.org.au/atdis/feed/1/atdis/1.0/applications.json")

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
