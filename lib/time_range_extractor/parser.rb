class Parser
  PATTERN = Regexp.new(
    "(?i)((?<start_time>[0-9]{1,2}:?[0-9]{0,2}?)\s?(?<start_period>am|pm)?\s?(-|until)\s?)?(?<end_time>[0-9]{1,2}:?[0-9]{0,2})?\s?(?<end_period>am|pm)\s?(?<time_zone>[a-z][sd]t)?",
    Regexp::IGNORECASE
  ).freeze

  def initialize(text, date: Date.current)
    @text = text
    @date = date
  end

  def call
    match_result = PATTERN.match(@text)
    return nil unless match_result

    result = MatchResult.new(match_result)

    start_time = time_from_string(result.start_time_string)
    end_time = time_from_string(result.end_time_string)

    start_time..end_time
  end

  private

  def time_from_string(string)
    time_parser.parse("#{@date.to_s(:db)} #{string}")
  end

  def time_parser
    ::Time.zone ? ::Time.zone : ::Time
  end
end
