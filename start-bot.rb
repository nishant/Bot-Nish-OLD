require 'discordrb'
require 'open-uri'
require 'json'
require 'psych'

bot = Discordrb::Commands::CommandBot.new(
    token: 'NTgxOTA5OTM3MTY5NjI5MTk1.XOmOyA.6obFYsF1bBd2_KNiXALvSXqNG7g',
    client_id: 359082109119365140,
    prefix: '%'
)

bot.command(:help) do |event|
    to_print = []

    to_print << 'Command List (begin with %):'
    to_print << 'ping - a test command to check if bot is up'
    to_print << 'marco - where\'s polo?'
    to_print << 'sum <num1 num2 ...> - sums a space-separated list of numbers'
    to_print << 'weather <zip code> - gets weather for a specified zip code'

    event.respond to_print.join("\n")
end

bot.message(with_text: 'ping') do |event|
  event.respond 'pong'
end

bot.message(with_text: 'marco') do |event|
    event.respond 'polo'
end

bot.command(:sum) do |event|
    numbers = event.message.content.split(' ')
    event.respond numbers.map(&:to_i).reduce(0, :+)
end

bot.command(:weather) do |event|
    api_key = '5be3960bf306ce17c9c742f07c351972'
    zip = event.message.content.split(' ')[1]
    request = "http://api.openweathermap.org/data/2.5/weather?zip=#{zip}&APPID=#{api_key}"
    response = open(request).readlines.join
    weather_data = JSON.parse(response)

    to_print = []
    to_print << "Location: ........... " + weather_data["name"].to_s.downcase
    to_print << "Temperature: ... " + (((weather_data["main"]["temp"].to_f - 273) * 9 / 5) + 32).ceil(2).to_s + ' °F'
    to_print << "Weather: ........... " + weather_data["weather"][0]["main"].to_s.downcase
    to_print << "Description: ...... " + weather_data["weather"][0]["description"].to_s
    to_print << "Humidity: .......... " + weather_data["main"]["humidity"].to_s + '%'
    to_print << "Low: .................... " + (((weather_data["main"]["temp_min"].to_f - 273) * 9 / 5) + 32).ceil(2).to_s + ' °F'
    to_print << "High: ................... " + (((weather_data["main"]["temp_max"].to_f - 273) * 9 / 5) + 32).ceil(2).to_s + ' °F'
    to_print << "Wind: ................. " + weather_data["wind"]["speed"].to_s + " mph"
    to_print << "Sunrise: .............. " + Time.at((weather_data["sys"]["sunrise"].to_f)).to_s.split(' ')[1].to_s
    to_print << "Sunset: ............... " + Time.at((weather_data["sys"]["sunset"].to_f)).to_s.split(' ')[1].to_s

    event.respond to_print.join("\n")
end

bot.run

