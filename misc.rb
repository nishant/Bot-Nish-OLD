def process_misc(bot)
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
end