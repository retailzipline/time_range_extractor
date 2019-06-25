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
end
