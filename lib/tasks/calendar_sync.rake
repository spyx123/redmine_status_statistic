require 'rest-client'
require 'json'


namespace :status_statistic do
  puts 'Updating calendar'

  task :calendar_sync do
    access_token = nil
    File.open("#{Rails.root}/config/data.gov.ru.secret", 'r') { |file| access_token = file.read }
    base_url = 'https://data.gov.ru/api/json/dataset/7708660670-proizvcalendar/version/'
  
    response = RestClient.get base_url, {params: {access_token: access_token}}
    versions = JSON.parse response
    last_version = versions[0]['created']
    
    response = RestClient.get base_url + last_version + '/content/', {params: {access_token: access_token}}
    File.open("#{Rails.root}/config/calendar.json", 'w') { |file| file.write response }
    
  end
end
