# frozen_string_literal: true

require 'test_helper'

class TimeRangeExtractorTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::TimeRangeExtractor::VERSION
  end

  [
    '5pm',
    '5pm EST',
    '5 pm',
    '5 AM CDT',
    '5:20pm',
    '5:20pm EST',
    '5:01 pm',
    '5:00 AM CDT',
    'Thu, 30 Jul 2020 5:00',
    'Thu, 30 Jul 2020 5:00pm',
    'Thu, 30 Jul 2020 5:00pm UTC',
  ].each do |time_string|
    define_method "test_should_not_handle_#{time_string.gsub(' ', '_')}" do
      assert_nil TimeRangeExtractor.call("Call at #{time_string} please")
    end
  end

  # rubocop:disable Style/WordArray
  [
    ['8-9am', ['8am', '9am']],
    ['4pm-5pm', ['4pm', '5pm']],
    ['4pm - 5pm', ['4pm', '5pm']],
    ['4 pm - 5 pm', ['4pm', '5pm']],
    ['4 pm - 5 pm EST', ['4pm EST', '5pm EST']],
    ['4:10pm - 5:00pm', ['4:10pm', '5pm']],
    ['4:10 pm - 5:00 pm EST', ['4:10pm EST', '5pm EST']],
    ['11am-1pm', ['11am', '1pm']]
  ].each do |time_string, range|
    define_method "test_should_handle_#{time_string.gsub(' ', '_')}" do
      result = TimeRangeExtractor.call("Call at #{time_string} please")
      assert_equal time_parser.parse(range[1]), result.end
      assert_equal time_parser.parse(range[0]), result.begin
    end
  end

  # Australian Time Zone mapping to work around ruby bug
  [
    ['4 pm - 5 pm AEST', ['16:00:00 EAST', '17:00:00 EAST']],
    ['4 pm - 5 pm AEDT', ['16:00:00 EADT', '17:00:00 EADT']],
    ['4 pm - 5 pm AWST', ['16:00:00 WAST', '17:00:00 WAST']],
    ['4 pm - 5 pm AWDT', ['16:00:00 WADT', '17:00:00 WADT']]
  ].each do |time_string, range|
    define_method "test_should_map_zones_for_#{time_string.gsub(' ', '_')}" do
      result = TimeRangeExtractor.call("Call at #{time_string} please")

      assert_equal time_parser.parse(range[1]), result.end
      assert_equal time_parser.parse(range[0]), result.begin
    end
  end

  [
    ['4-5pm', ['4pm', '5pm']],
    ['11-12pm', ['11am', '12pm']],
    ['12:10-12:30pm', ['12:10pm', '12:30pm']]
  ].each do |time_string, range|
    define_method "test_should_handle_#{time_string.gsub(' ', '_')}" do
      result = TimeRangeExtractor.call("Call at #{time_string} please")

      assert_equal time_parser.parse(range[0]), result.begin
      assert_equal time_parser.parse(range[1]), result.end
    end
  end

  [
    '5 america',
    '5:00:00america',
    'PST',
    '2005 america',
    '5:1 pm',
    '5:61 pm',
    '25:10',
    '30:10 pm',
    '0:00'
  ].each do |not_a_time|
    define_method "test_should_ignore_#{not_a_time.gsub(' ', '_')}" do
      result = TimeRangeExtractor.call("Random text #{not_a_time} for context")

      assert_nil result
    end
  end
  # rubocop:enable Style/WordArray

  def test_should_span_days_if_necessary
    result = TimeRangeExtractor.call('Random text 11pm - 1am for context')

    assert_equal time_parser.parse('11pm'), result.begin
    assert_equal time_parser.parse('1am') + 1.day, result.end
  end

  def test_should_return_nil_if_no_times_found
    result = TimeRangeExtractor.call('Call me today please')

    assert_nil result
  end

  def test_should_only_return_the_first_match
    result = TimeRangeExtractor.call(
      'The meeting is from 4-5pm but we will follow up from 6-7pm'
    )

    assert_equal time_parser.parse('4pm'), result.begin
    assert_equal time_parser.parse('5pm'), result.end
  end

  def test_should_handle_line_breaks
    result = TimeRangeExtractor.call(<<~TEXT)
      Hi there,

      Can you call me from 4-5pm
    TEXT

    assert_equal time_parser.parse('4pm'), result.begin
    assert_equal time_parser.parse('5pm'), result.end
  end

  def test_should_handle_times_at_the_start_of_the_string
    result = TimeRangeExtractor.call('8-8:30am')

    assert_equal time_parser.parse('8am'), result.begin
    assert_equal time_parser.parse('8:30am'), result.end
  end

  def test_should_return_times_in_current_time_zone_if_set
    Time.use_zone 'America/Vancouver' do
      result = TimeRangeExtractor.call('Call me from 5-6pm')

      zone = Time.zone

      assert_equal zone.parse('5pm'), result.begin
      assert_equal zone.parse('6pm'), result.end
    end
  end

  def test_should_return_times_from_other_time_zones_in_current_time_zone_if_set
    Time.use_zone 'America/Vancouver' do
      result = TimeRangeExtractor.call('Call me from 5-6pm EST')

      begins_at = result.begin

      assert_equal Time.zone.parse('5pm EST').utc, begins_at.utc
      assert_equal 'America/Vancouver', begins_at.time_zone.name
    end
  end

  def test_should_support_valid_examples
    [
      'Call: Launch meeting (9:15-10:15am)',
      'Watch for risks from 6pm until 7:30pm CET'
    ].each do |text_with_valid_time|
      assert_kind_of Range, TimeRangeExtractor.call(text_with_valid_time)
    end
  end

  [
    'to',
    'until',
    '-'
  ].each do |separator|
    define_method "test_should_support_the_#{separator}_separator" do
      result = TimeRangeExtractor.call("8#{separator}9pm")

      assert_kind_of Range, result
      assert_equal time_parser.parse('8pm'), result.begin
      assert_equal time_parser.parse('9pm'), result.end
    end
  end

  private

  def time_parser
    DateTime
  end
end
