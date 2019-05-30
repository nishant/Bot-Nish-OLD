def process_stock(bot)
	bot.command(:stock) do |event|
		api_key = get_stock_api_key()
		keyword = event.message.content.sub("%stock", "")
		request = "https://www.alphavantage.co/query?function=SYMBOL_SEARCH&keywords=#{keyword}&apikey=#{api_key}"
		response = open(request).readlines.join
		search_data = JSON.parse(response)
	
		symbol = search_data["bestMatches"][0]["1. symbol"]
	
		request = "https://www.alphavantage.co/query?function=TIME_SERIES_DAILY&symbol=#{symbol}&apikey=#{api_key}"
		response = open(request).readlines.join
		stock_data = JSON.parse(response)
		
		most_recent = stock_data["Meta Data"]["3. Last Refreshed"].split(' ')[0]
	
		info = stock_data["Time Series (Daily)"][most_recent]
		
		event.channel.send_embed("") do |embed|
			create_stock_embed(embed, symbol, search_data, info)
		end
	end
end

def create_stock_embed(embed, symbol, search_data, info)
	embed.title = "Stock Data for #{symbol}"
	embed.url = URI.encode("https://www.google.com/search?q=stock+#{symbol.upcase}")
	embed.timestamp = Time.now
	
	embed.footer = Discordrb::Webhooks::EmbedFooter.new(
		text: "Alpha Vantage", 
		icon_url: "http://pngimg.com/uploads/dollar_sign/dollar_sign_PNG21539.png"
	)

	embed.add_field(
		name: "Stock Data:",
		value:  "Company .................. " + search_data["bestMatches"][0]["2. name"] + "\n" +
				"Symbol ...................... " + search_data["bestMatches"][0]["1. symbol"] + "\n" +
				"Open .......................... " + '%.2f' % info["1. open"].to_f.ceil(2).to_s + "\n" +
				"Close .......................... " + '%.2f' % info["4. close"].to_f.ceil(2).to_s + "\n" +
				"High ............................ " + '%.2f' % info["2. high"].to_f.ceil(2).to_s + "\n" +
				"Low ............................. " + '%.2f' % info["3. low"].to_f.ceil(2).to_s + "\n",
		inline: true
	)
end
