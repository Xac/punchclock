class Time
  def formatted(only)
    format = TIME_FORMAT if only == :time
    format = DATE_FORMAT if only == :date
    format ||= DATETIME_FORMAT
    self.strftime(format)
  end
end