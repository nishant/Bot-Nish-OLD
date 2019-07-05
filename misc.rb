def process_misc(bot, time)
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

	# bot.command(:uptime) do |event|
	# 	event.channel.send_embed("") do |embed|
	# 		embed.color = 0x35e500

	# 		now = Time.parse(Time.now.to_s)
	# 		start = Time.parse(time.to_s)

	# 		uptime = now - start

	# 		days = (uptime / (24 * 3600))
	# 		hours = ((uptime % (24 * 3600)) / 3600)
	# 		mins = ((uptime % (24 * 3600 * 3600)) / 60)
	# 		secs = ((uptime % (24 * 3600 * 3600 * 60)) / 60)

	# 		embed.add_field(
	# 			name: "Uptime:",
	# 			value: "Bot Nish has been online for #{days} days, #{hours} hours, #{mins} mins, #{secs} secs.",
	# 			inline: false
	# 		)
	# 	end
	# end
end