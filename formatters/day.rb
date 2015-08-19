class Timetrap::Formatters::Day
  include Timetrap::Helpers

  DATE_FORMAT = '%Y/%m/%d'

  def initialize(entries)
    @entries = entries
    @total_day_target = hours_to_seconds(Timetrap::Config['day_length_hours'].to_f)
    @width = Timetrap::Config['progress_width'].to_f
    @skip = Timetrap::Config['day_exclude_sheets'] || []
    @countdown = Timetrap::Config['day_countdown']
    @start_time = Timetrap::Config['day_start'] || 0
    @now = Time.now.round
    @start_today = Time.new(@now.year, @now.month, @now.day) + @start_time
    if @start_today < @now
      @day_start = @start_today
      @day_end = add_day(@day_start, 1)
    else
      @day_start = add_day(@day_start, -1)
      @day_end = @start_today
    end
  end

  def output
    output = ''
    todays_duration = 0.0
    @entries.each do |entry|
      if !@skip.include?(entry.sheet)
        todays_duration += get_duration_today(entry.start, entry.end_or_now)
      end
    end
    percentage = ((todays_duration/@total_day_target)*100).to_i
    output << '[' << progress_bar(percentage) << '] ' << percentage.to_s << "%\n"
    remaining = @countdown ? format_seconds((@total_day_target - todays_duration).to_int) : ''
    output << "%%s%%%ds" % (@width - 7) % [format_seconds(todays_duration.round), remaining]
    return output
  end

  def add_day(t, d)
    Time.new(t.year, t.month, t.day + d, t.hour, t.min, t.sec)
  end
  private :add_day

  def get_duration_today(s, e)
    if e < @day_start
      0
    else
      e - [s, @day_start].max
    end
  end
  private :get_duration_today

  def hours_to_seconds(hour_amount)
    return (hour_amount * 60.0 * 60.0)
  end
  private :hours_to_seconds

  def progress_bar(percentage)
    if percentage < 100
      hash_num = ((@width/100.0) * percentage).round()
      space_num = @width - hash_num
      return '#' * hash_num << ' ' * space_num
    else
      return '#' * @width
    end
  end
  private :progress_bar

end
