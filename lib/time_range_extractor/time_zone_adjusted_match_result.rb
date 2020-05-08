# frozen_string_literal: true

module TimeRangeExtractor
  class TimeZoneAdjustedMatchResult < MatchResult
    # This works around Ruby's lack of support for the following timezones.
    # It has been fixed in Ruby 2.7.x versions.  Until we are able to upgrade
    # this mapping will help but it's not a complete fix as
    # Central Australian times aren't handled.
    #
    # More details:
    #  * https://github.com/ruby/date/pull/16
    #  * https://github.com/rails/rails/issues/36972#issuecomment-526260754
    def time_zone
      case match_data[:time_zone]
      when 'AEST' then 'EAST'
      when 'AWST' then 'WAST'
      when 'AEDT' then 'EADT'
      when 'AWDT' then 'WADT'
      else super
      end
    end
  end
end
