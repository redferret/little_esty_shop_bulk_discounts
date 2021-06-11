module ApiCalls

  def current_date
    Time.now
  end

  def date_of_the(holiday)
    Time.parse(holiday['date'])
  end
  
  def upcoming_holidays
    year = Time.now.year
    holidays = request endpoint: "/api/v3/PublicHolidays/#{year}/US"
    
    holidays.find_all do |holiday|
      current_date < (date_of_the holiday)
    end[0..2]
  end
end