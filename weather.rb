def kelvin_to_fahrenheit(value)
    return (((value.to_f - 273) * 9 / 5) + 32).ceil(2)
end

def process_weather(bot)
	bot.command(:weather) do |event|
		api_key = get_weather_api_key()
		zip = event.message.content.split(' ')[1]

		request = "http://api.openweathermap.org/data/2.5/weather?zip=#{zip}&APPID=#{api_key}"
		response = open(request).readlines.join
		weather_data = JSON.parse(response)
	
		event.channel.send_embed("") do |embed|
			create_weather_embed(embed, zip, weather_data)
		end
	end
end

def create_weather_embed(embed, zip, weather_data)
	embed.title = "Weather Data for #{zip}"
	embed.url = URI.encode("https://www.google.com/search?q=weather+#{zip}")
	embed.timestamp = Time.now
	
	embed.footer = Discordrb::Webhooks::EmbedFooter.new(
		text: "Open Weather Map", 
		icon_url: "https://cdn1.iconfinder.com/data/icons/weather-elements/512/Weather_SunAbstract.png"
	)
	
	embed.add_field(
		name: "Current Weather:",
		value:  "Location: ..................... " + weather_data["name"].to_s.downcase + "\n" +
				"Temperature: ............. " + kelvin_to_fahrenheit(weather_data["main"]["temp"]).to_s + ' °F' + "\n" +
				"Weather: ..................... " + weather_data["weather"][0]["main"].to_s.downcase + "\n" +
				"Description: ................ " + weather_data["weather"][0]["description"].to_s + "\n" +
				"Humidity: .................... " + weather_data["main"]["humidity"].to_s + '%' + "\n" +
				"Low: .............................. " + kelvin_to_fahrenheit(weather_data["main"]["temp_min"]).to_s + ' °F' + "\n" +
				"High: ............................. " + kelvin_to_fahrenheit(weather_data["main"]["temp_max"]).to_s + ' °F' + "\n" +
				"Wind: ........................... " + weather_data["wind"]["speed"].to_s + " mph" + "\n" +
				"Sunrise: ........................ " + Time.at((weather_data["sys"]["sunrise"].to_f)).strftime("%l:%M %p").to_s.lstrip() + "\n" +
				"Sunset: ......................... " + Time.at((weather_data["sys"]["sunset"].to_f)).strftime("%l:%M %p").to_s.lstrip() + "\n",
		inline: true
	)
end
