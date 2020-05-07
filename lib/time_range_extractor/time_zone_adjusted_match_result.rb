# frozen_string_literal: true

module TimeRangeExtractor
  class TimeZoneAdjustedMatchResult < MatchResult
    def time_zone
      case match_data[:time_zone]
      when "AEST"
        "EAST"
      when "AWST"
        "WAST"
      when "AEDT"
        "EADT"
      when "AWDT"
        "WADT"
      else
        match_data[:time_zone]
      end
    end
  end
end
