require 'discordrb'
require 'open-uri'
require 'json'
require 'psych'

api_key = '3KT67VI8256BBOXC'
symbol = 'AAPL'
request = "https://www.alphavantage.co/query?function=TIME_SERIES_DAILY&symbol=#{symbol}&apikey=#{api_key}"
response = open(request).readlines.join
stock_data = JSON.parse(response)
most_recent = stock_data["Meta Data"]["3. Last Refreshed"]
info = stock_data["Time Series (Daily)"][most_recent]

p info