# Raised on invalid TOML strings.
class TOML::ParseException < Exception
  # The line number where the invalid TOML was detected.
  getter line_number : Int32

  # The column number where the invalid TOML was detected.
  getter column_number : Int32

  # Creates a ParseException with the given message, line number and column number.
  def initialize(message, @line_number, @column_number)
    super "#{message} at #{@line_number}:#{@column_number}"
  end
end
