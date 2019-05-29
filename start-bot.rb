require 'discordrb'
require 'open-uri'
require 'json'
require 'psych'
require 'httparty'

require_relative 'help.rb'
require_relative 'misc.rb'
require_relative 'weather.rb'
require_relative 'stock.rb'
require_relative 'fortnite.rb'

bot = Discordrb::Commands::CommandBot.new(
    token: 'NTgxOTA5OTM3MTY5NjI5MTk1.XOmOyA.6obFYsF1bBd2_KNiXALvSXqNG7g',
    client_id: 359082109119365140,
    prefix: '%'
)

process_help(bot)
process_misc(bot)
process_weather(bot)
process_stock(bot)
process_weather(bot)
process_fn(bot)

bot.run

