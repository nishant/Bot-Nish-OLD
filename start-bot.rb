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
    to_print << "Location: ............. " + weather_data["name"].to_s.downcase
    to_print << "Temperature: ..... " + (((weather_data["main"]["temp"].to_f - 273) * 9 / 5) + 32).ceil(2).to_s + ' °F'
    to_print << "Weather: ............. " + weather_data["weather"][0]["main"].to_s.downcase
    to_print << "Description: ........ " + weather_data["weather"][0]["description"].to_s
    to_print << "Humidity: ............ " + weather_data["main"]["humidity"].to_s + '%'
    to_print << "Low: ...................... " + (((weather_data["main"]["temp_min"].to_f - 273) * 9 / 5) + 32).ceil(2).to_s + ' °F'
    to_print << "High: ..................... " + (((weather_data["main"]["temp_max"].to_f - 273) * 9 / 5) + 32).ceil(2).to_s + ' °F'
    to_print << "Wind: ................... " + weather_data["wind"]["speed"].to_s + " mph"
    to_print << "Sunrise: ................ " + Time.at((weather_data["sys"]["sunrise"].to_f)).strftime("%l:%M %p").to_s.lstrip()
    to_print << "Sunset: ................. " + Time.at((weather_data["sys"]["sunset"].to_f)).strftime("%l:%M %p").to_s.lstrip()

    event.respond to_print.join("\n")
end

bot.command(:stock) do |event|
    api_key = '3KT67VI8256BBOXC'
    keyword = event.message.content.sub("%stock", "")
    request = "https://www.alphavantage.co/query?function=SYMBOL_SEARCH&keywords=#{keyword}&apikey=#{api_key}"
    response = open(request).readlines.join
    search_data = JSON.parse(response)
    to_print = []

    to_print << "Company ...... " + search_data["bestMatches"][0]["2. name"]
    to_print << "Symbol .......... " + search_data["bestMatches"][0]["1. symbol"]

    symbol = search_data["bestMatches"][0]["1. symbol"]
    request = "https://www.alphavantage.co/query?function=TIME_SERIES_DAILY&symbol=#{symbol}&apikey=#{api_key}"
    response = open(request).readlines.join
    stock_data = JSON.parse(response)

    most_recent = stock_data["Meta Data"]["3. Last Refreshed"]
    info = stock_data["Time Series (Daily)"][most_recent]
    
    to_print << "Open .............. " + '%.2f' % info["1. open"].to_f.ceil(2)
    to_print << "Close .............. " + '%.2f' % info["4. close"].to_f.ceil(2).to_s
    to_print << "High ................ " + '%.2f' % info["2. high"].to_f.ceil(2).to_s
    to_print << "Low ................. " + '%.2f' % info["3. low"].to_f.ceil(2).to_s

    event.respond to_print.join("\n")
end

bot.run

