module TimeTools
  # Convert seconds into hours, minutes, and seconds
  def seconds_fraction_to_time(seconds)
    hours = mins = 0
    if seconds >=  60
      mins = (seconds / 60).to_i 
      seconds = (seconds % 60 ).to_i
      if mins >= 60
        hours = (mins / 60).to_i 
        mins = (mins % 60).to_i
      end
    end
    [hours,mins,seconds]
  end
  
  # Difference between two times in words
  def time_difference(from,to=Time.now)
    hours, minutes, seconds = seconds_fraction_to_time(to-from)
    t = []
    t.push hours.round.to_s+" hour(s)" if hours > 0
    t.push minutes.round.to_s+" minute(s)" if minutes > 0
    t.push seconds.round.to_s+" second(s)" if minutes < 1 && hours < 1
    t.join ", "
  end
  
  # Shortcut for making a sentence from seconds
  def time_in_words(seconds)
    time_difference Time.now-seconds
  end
  
  # Same as time_in_words, but includes the hours decimal ie: (4.56)
  def time_in_words_with_dec(seconds)
    "#{time_in_words(seconds)} (#{((seconds.to_f/60)/60).round(2)})"
  end
end
