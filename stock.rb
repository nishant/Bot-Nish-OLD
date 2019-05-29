def process_stock(bot)
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
		
		most_recent = stock_data["Meta Data"]["3. Last Refreshed"].split(' ')[0]
	
		info = stock_data["Time Series (Daily)"][most_recent]
		
		to_print << "Open .............. " + '%.2f' % info["1. open"].to_f.ceil(2)
		to_print << "Close .............. " + '%.2f' % info["4. close"].to_f.ceil(2).to_s
		to_print << "High ................ " + '%.2f' % info["2. high"].to_f.ceil(2).to_s
		to_print << "Low ................. " + '%.2f' % info["3. low"].to_f.ceil(2).to_s
	
		event.respond to_print.join("\n")
	end
end