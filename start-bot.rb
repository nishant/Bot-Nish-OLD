# cntrl + b, d to detach in tmux

# TODO:
# 	remindme
#	sunset bug
#	send file when too many cards to list
#	
require 'discordrb'
require 'open-uri'
require 'json'
require 'psych'
require 'httparty'
require 'dentaku'
require 'time'
# require 'youtube-dl.rb'
# require 'open3'

require_relative 'secrets.rb'
require_relative 'help.rb'
require_relative 'misc.rb'
require_relative 'weather.rb'
require_relative 'stock.rb'
require_relative 'fortnite.rb'
require_relative 'math.rb'
require_relative 'yugioh.rb'
require_relative 'media.rb'
require_relative 'generate.rb'

bot = Discordrb::Commands::CommandBot.new(
    token: get_discord_token(),
    client_id: 581909937169629195,
    prefix: '%'
)

time = Time.now

process_help(bot)
process_misc(bot, time)
process_weather(bot)
process_stock(bot)
process_weather(bot)
process_fn(bot)
process_math(bot)
process_yugioh(bot)
# process_media(bot)
process_generate(bot)

bot.run