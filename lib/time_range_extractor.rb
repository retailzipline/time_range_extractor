require "time"
require "date"
require "active_support/time"

require "time_range_extractor/match_result"
require "time_range_extractor/parser"
require "time_range_extractor/version"

module TimeRangeExtractor
  class Error < StandardError; end

  def self.call(text, date: Date.current)
    Parser.new(text, date: date).call
  end
end
