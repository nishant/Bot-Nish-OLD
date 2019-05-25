require 'open-uri'
require 'json'
require 'psych'
api_key = '5be3960bf306ce17c9c742f07c351972'
zip = "20740"
request = "http://api.openweathermap.org/data/2.5/weather?zip=#{zip}&APPID=#{api_key}"
response = open(request).readlines.join


def format_time(x)
    x.to_s.sub(/^(\d{1,2})(\d{2})$/,'\1:\2')
end

hash = JSON.parse(response)
# p hash["name"]
# p hash["main"]["temp"]
# p hash["main"]["humidity"]
p hash["main"]["temp_min"]
p hash["main"]["temp_max"]
# p hash["weather"][0]["main"]
p hash["weather"][0]["description"] 
p hash["wind"]["speed"]
p hash["sys"]["sunrise"]
p hash["sys"]["sunset"]

sec = (hash["sys"]["sunrise"].to_f).to_s

x =  Time.at((hash["sys"]["sunrise"].to_f)).to_s.split(' ')[1]
puts format_time(x)



# print Psych.dump(JSON.parse(response))