require 'discordrb'
require 'open-uri'
require 'json'
require 'psych'
require 'httparty'
require 'dentaku'

require_relative 'secrets.rb'
require_relative 'help.rb'
require_relative 'misc.rb'
require_relative 'weather.rb'
require_relative 'stock.rb'
require_relative 'fortnite.rb'
require_relative 'math.rb'

bot = Discordrb::Commands::CommandBot.new(
    token: get_discord_token(),
    client_id: 359082109119365140,
    prefix: '%'
)

process_help(bot)
process_misc(bot)
process_weather(bot)
process_stock(bot)
process_weather(bot)
process_fn(bot)
process_math(bot)

bot.run

