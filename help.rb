def process_help(bot)
	bot.command(:help) do |event|
		to_print = []

		to_print << 'Command List (begin with %):'
		to_print << 'ping - a test command to check if bot is up'
		to_print << 'marco - where\'s polo?'
		to_print << 'sum <num1 num2 ...> - sums a space-separated list of numbers'
		to_print << 'weather <zip code> - gets weather for a specified zip code'

		event.respond to_print.join("\n")
	end
end