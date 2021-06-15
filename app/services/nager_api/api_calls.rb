module ApiCalls
  def upcoming_holidays
    holidays = request endpoint: "/api/v3/NextPublicHolidays/US"
    holidays[0..2]
  end
end