# frozen_string_literal: true

# Parse out time values from a string of text. Uses the provided date as the
# basis for the DateTime generation.
class Parser
  PATTERN = /
    (?i)
    (
      (?<start_time>[0-9]{1,2}:?[0-9]{0,2}?)\s?
      (?<start_period>am|pm)?\s?
      (-|until)\s?
    )?
    (?<end_time>[0-9]{1,2}:?[0-9]{0,2})?\s?
    (?<end_period>am|pm)\s?
    (?<time_zone>[a-z][sd]t)?\b
  /xi.freeze

  def initialize(text, date: Date.current)
    @text = text
    @date = date
  end

  def call
    result = PATTERN.match(@text)
    result && time_range_from(MatchResult.new(result))
  end

  private

  def time_range_from(match_result)
    start_time = time_from_string(match_result.start_time_string)
    end_time = time_from_string(match_result.end_time_string)

    if start_time <= end_time
      start_time..end_time
    elsif start_time > end_time
      start_time..(end_time + 1.day)
    end
  end

  def time_from_string(string)
    time_parser.parse("#{@date.to_s(:db)} #{string}")
  end

  # :reek:UtilityFunction so that we can optionally include ActiveSupport
  def time_parser
    ::Time.zone || ::Time
  end
end
