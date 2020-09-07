require 'json'

BusinessTime::Config.load("#{Rails.root}/config/business_time.yml")

# or you can configure it manually:  look at me!  I'm Tim Ferriss!
#  BusinessTime::Config.beginning_of_workday = "10:00 am"
#  BusinessTime::Config.end_of_workday = "11:30 am"
#  BusinessTime::Config.holidays << Date.parse("August 4th, 2010")

raw_data = nil

File.open("#{Rails.root}/config/calendar.json") { |file| raw_data = file.read }
json_calendar = JSON.parse(raw_data)


months = ["Январь", "Февраль", "Март", "Апрель", "Май", "Июнь", "Июль",
  "Август", "Сентябрь", "Октябрь", "Ноябрь", "Декабрь"]

json_calendar.each do | year_data |
  year = year_data["Год/Месяц"].to_i
  month = 1
  months.each do | month_name |
    days = year_data[month_name]
      days.split(',').each do | day |
        BusinessTime::Config.holidays << Date.new(year, month, day.to_i)
      end
    month += 1
  end
end
