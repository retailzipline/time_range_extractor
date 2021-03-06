# frozen_string_literal: true

# Parse out time values from a string of text. Uses the provided date as the
# basis for the DateTime generation.
module TimeRangeExtractor
  class Parser
    PATTERN = /
      (\A|\s|\() # space or round bracket, to support: "Call Jim (8-9pm)"
      (
        (?<start_time>(2[0-4]|1[0-9]|[1-9])(:[0-5][0-9])?)\s?
        (?<start_period>am|pm)?\s?
        (to|-|—|–|until|\s)\s?
      )
      (?<end_time>(2[0-4]|1[0-9]|[1-9])(:[0-5][0-9])?)?\s?
      (?<end_period>am|pm)\s?
      (?<time_zone>(
        [ABCDEFGHIJKLMNOPRSTUVWY]
        [A-Z]
        [ACDEGHKLMNORSTUVW]?
        [CDNSTW]?
        [T]?
      ))?\b
    /xi.freeze

    def initialize(text, date: Date.current)
      @text = text
      @date = date
      @dst = date.to_time.in_time_zone('America/New_York').dst?
    end

    def call
      match = PATTERN.match(@text)
      result = TimeZoneAdjustedMatchResult.new(match, dst: @dst)
      return nil unless result.valid?

      time_range_from(result)
    end

    private

    def time_range_from(match_result)
      start_time = time_from_string(match_result.start_time_string)
      end_time = time_from_string(match_result.end_time_string)

      return nil unless start_time && end_time

      if start_time <= end_time
        start_time..end_time
      elsif start_time > end_time
        start_time..(end_time + 1.day)
      end
    end

    # Time.zone and DateTime parse invalid times differently. DateTime
    # throws an ArgumentError while Time.zone returns nil.
    #
    # So, we rescue ArgumentError so that this method always returns nil
    # when invalid values are passed
    def time_from_string(string)
      time_parser.parse(string, @date.to_time)
    rescue ArgumentError
      nil
    end

    # :reek:UtilityFunction so that we can optionally include ActiveSupport
    def time_parser
      ::Time.zone || ::DateTime
    end
  end
end
