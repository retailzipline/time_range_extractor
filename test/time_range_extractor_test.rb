require "test_helper"

class TimeRangeExtractorTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::TimeRangeExtractor::VERSION
  end

  [
    "5pm",
    "5pm EST",
    "5 pm",
    "5 AM CDT",
    "5:20pm",
    "5:20pm EST",
    "5:01 pm",
    "5:00 AM CDT"
  ].each do |time_string|
    define_method "test_should_properly_handle_the_simple_case_of_#{time_string}" do
      result = TimeRangeExtractor.call("Call at #{time_string} please")

      time = Time.parse(time_string)

      assert_equal time, result.begin
      assert_equal time, result.end
    end
  end

  # rubocop:disable Style/WordArray
  [
    ["4pm-5pm", ["4pm", "5pm"]],
    ["4pm - 5pm", ["4pm", "5pm"]],
    ["4 pm - 5 pm", ["4pm", "5pm"]],
    ["4 pm - 5 pm EST", ["4pm EST", "5pm EST"]],
    ["4:10pm - 5:00pm", ["4:10pm", "5pm"]],
    ["4:10 pm - 5:00 pm EST", ["4:10pm EST", "5pm EST"]],
    ["11am-1pm", ["11am", "1pm"]]
  ].each do |time_string, range|
    define_method "test_should_properly_handle_the_simple_range_case_of_#{time_string}" do
      result = TimeRangeExtractor.call("Call at #{time_string} please")

      assert_equal Time.parse(range[0]), result.begin
      assert_equal Time.parse(range[1]), result.end
    end
  end

  [
    ["4-5pm", ["4pm", "5pm"]],
    ["11-12pm", ["11am", "12pm"]],
    ["12:10-12:30pm", ["12:10pm", "12:30pm"]]
  ].each do |time_string, range|
    define_method "test_should_properly_handle_the_complex_range_case_of_#{time_string}" do
      result = TimeRangeExtractor.call("Call at #{time_string} please")

      assert_equal Time.parse(range[0]), result.begin
      assert_equal Time.parse(range[1]), result.end
    end
  end
  # rubocop:enable Style/WordArray

  def test_should_return_nil_if_no_times_found
    result = TimeRangeExtractor.call("Call me today please")

    assert_nil result
  end

  def test_should_handle_line_breaks
    result = TimeRangeExtractor.call(<<~TEXT)
      Hi there,

      Can you call me from 4-5pm
    TEXT

    assert_equal Time.parse('4pm'), result.begin
    assert_equal Time.parse('5pm'), result.end
  end

  def test_should_return_times_in_current_time_zone_if_set
    Time.use_zone 'America/Vancouver' do
      result = TimeRangeExtractor.call("Call me at 5pm")

      assert_equal Time.zone.parse('5pm'), result.begin
    end
  end

  def test_should_return_times_from_other_time_zones_in_current_time_zone_if_set
    Time.use_zone 'America/Vancouver' do
      result = TimeRangeExtractor.call("Call me at 5pm EST")

      assert_equal Time.parse('5pm EST').utc, result.begin.utc
      assert_equal 'America/Vancouver', result.begin.time_zone.name
    end
  end
end
