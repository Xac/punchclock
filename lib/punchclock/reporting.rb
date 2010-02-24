module PunchClock
  module Reporting
    def status
      string = clocked_in? ? "In since #{last_in_time.formatted(:time)}" : "Out since #{last_out_time.formatted(:time)}" 
    
      string                                                      <<
      "\nTime in today: #{start_time_today.formatted(:time)}"     <<
      "\n————————————————"                                        <<
      "\nTotal in: #{time_in_words(time_in_today)}"               <<
      "\nTotal out: #{time_in_words(time_out_today)}"             <<
      "\n————————————————"                                        <<
      "\nCurrent category: #{@category.name}"                     <<
      "\n————————————————"                                        <<
      "\nOut time: #{out_time.formatted(:time)}"                  <<
      "\n————————————————"                                        <<
      "\nTime left: #{time_left}"                                 <<
      "\n————————————————"
      notify string
    end
  
    def week_history(opt=:this,include_lists=false)
      start_time = [Date,DateTime,Time].include?(opt.class) ? opt.to_time : Time.now
    
      week_start = start_time.at_beginning_of_week-2.days            
      week_end = start_time.at_end_of_week-2.days
      
      # Subtract a week if last is specified
      week_start,week_end = [week_start-1.week,week_end-1.week] if opt == :last 
      
      week_total = total_seconds_for(week_start..week_end)
  
      day = (opt == :this ? Time.now.strftime("%w").to_i : 5)
      required = day * @hours_per_day
      actual = (total_seconds_for(week_start..(week_start+(day+1).days).end_of_day).to_f/60)/60
  
      if (actual <= required)
        over_or_under = "#{time_in_words((required-actual).hours)} (#{(required-actual).round(2)}) behind."
      else
        over_or_under = "#{time_in_words((actual-required).hours)} (#{(actual-required).round(2)}) ahead"
      end

      notification = "Total time for week ending #{week_end.formatted(:date)}"                                      <<
      "\n#{time_in_words(week_total)}"                                                                              <<
      "\n————————————————"                                                                                          <<
      "\n#{over_or_under}"                                                                                          <<
      "\n————————————————"                                                                                          <<
      "\nSaturday: #{time_in_words_with_dec(total_seconds_for(week_start..week_start.end_of_day))}"                 <<
      "\nSunday: #{time_in_words_with_dec(total_seconds_for(week_start+1.day..(week_start+1.day).end_of_day))}"     <<
      "\nMon: #{time_in_words_with_dec(total_seconds_for(week_start+2.days..(week_start+2.days).end_of_day))}"      <<
      "\nTue: #{time_in_words_with_dec(total_seconds_for(week_start+3.days..(week_start+3.days).end_of_day))}"      <<
      "\nWed: #{time_in_words_with_dec(total_seconds_for(week_start+4.days..(week_start+4.days).end_of_day))}"      <<
      "\nThu: #{time_in_words_with_dec(total_seconds_for(week_start+5.days..(week_start+5.days).end_of_day))}"      <<
      "\nFri: #{time_in_words_with_dec(total_seconds_for(week_start+6.days..(week_start+6.days).end_of_day))}"
    
      if include_lists
        notification << "\n"
        ins,outs = get_ins_and_outs_for((week_start+2.days)..(week_start+6.days).end_of_day)
        (ins+outs).sort{|a,b| a.time <=> b.time }.each do |time|
          notification << "\n#{time.time.formatted}: #{time.class}"
        end
      end
    
      notify notification
    end
    
    def week_summary_list
      first_history = In.find(:first, :order => "time ASC")
      end_of_week = first_history.time.end_of_week-2.days
      beginning_of_week = end_of_week.beginning_of_week-2.days
      output = []
    
      while beginning_of_week <= Time.now do
        output << end_of_week.formatted(:date)+" : #{time_in_words_with_dec(total_seconds_for(beginning_of_week..end_of_week))}"
        end_of_week += 1.week
        beginning_of_week += 1.week
      end
    
      notify output.join('\n')
    end
    
    # End of day time
    def out_time
      start_time_today + @hours_per_day.hours + time_out_today
    end
    
    # Total time spent clocked out for the day
    def time_out_today
      Time.now - start_time_today - time_in_today
    end
  
    # Total time spent clocked in for the day
    def time_in_today
      total_seconds_for(Date.today.beginning_of_day..Date.today.end_of_day)
    end
  
    # Return ins and outs for a given range
    def get_ins_and_outs_for(range)
      start_time,end_time = [range.first, range.last]
    
      first_s,last_s = start_time.to_s(:db),end_time.to_s(:db)
      [
        In.find(:all, :conditions => ["time BETWEEN '#{first_s}' AND '#{last_s}'"], :order => "time ASC"),
        Out.find(:all, :conditions => ["time BETWEEN '#{first_s}' AND '#{last_s}'"], :order => "time ASC")
      ]
    end
  
    # Return the amount of clocked in seconds for a given range
    def total_seconds_for(range)
      first,last = [range.first, range.last]
    
      total_time = 0
      add_time = 0
      ins,outs = get_ins_and_outs_for(range)
      if !outs.empty? && ((!ins.empty? && outs.first[:time] < ins.first[:time]) || ins.empty?)
        add_time = outs.first.time - first
        outs -= [outs.first]
      end
      while(!ins.empty? && !outs.empty?)
        unless outs.blank?
          total_time += outs.first[:time]-ins.first[:time]
          outs -= [outs.first]
        end
        ins -= [ins.first]
      end
      total_time += (Time.now-last_in_time) if (last >= Time.now) && (first < Time.now) && clocked_in?
      total_time + add_time
    end
    
    # Time left in the day
    def time_left
      time_difference(Time.now,out_time)
    end
  end
end