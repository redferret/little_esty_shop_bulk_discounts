module ApiCalls

  def current_time
    Time.now
  end
  
  def upcoming_holidays
    year = Time.now.year
    holidays = request endpoint: "/api/v3/PublicHolidays/#{year}/US"
    
    holidays.filter_map do |holiday|
      holiday if current_time < Time.parse(holiday['date'])
    end[0..2]
  end
end