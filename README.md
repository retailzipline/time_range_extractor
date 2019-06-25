# Time Range Extractor

This gem makes it easy to extract a time range from some text. The goal is to be able to pull out start and end times from a body of text so that you can give more context to the information.

For example:

```ruby
result = TimeRangeExtractor.call("Meet with Jessie from 4-5pm")
result.begin
#=> 2019-06-20 16:00:00 -0700
result.end
#=> 2019-06-20 17:00:00 -0700
```

A few caveats:

- Only reads out the first time it can find
- If only one time is found, that becomes the start time
- Only the last time zone is taken into account
- Doesn't support 24 hour clocks yet
- Likely no support for international times
- Check the test suite for supported cases

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'time_range_extractor'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install time_range_extractor

## Usage

```ruby
result = TimeRangeExtractor.call("Meet with Jessie from 4-5pm")
result.begin
#=> 2019-06-24 16:00:00 -0700
result.end
#=> 2019-06-24 17:00:00 -0700

result = TimeRangeExtractor.call("Meet with Jessie at 4pm EDT", date: 4.days.ago.to_date)
result.begin
#=> 2019-06-20 16:00:00 -0400
result.end
#=> 2019-06-20 16:00:00 -0400

Time.zone = 'America/Vancouver'

result = TimeRangeExtractor.call("Meet with Jessie at 4pm EDT", date: 4.days.ago.to_date)
result.begin
#=> Thu, 20 Jun 2019 13:00:00 PDT -07:00
result.end
#=> Thu, 20 Jun 2019 13:00:00 PDT -07:00
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/retailzipline/time_range_extractor.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
