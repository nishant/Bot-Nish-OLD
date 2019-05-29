def process_help(bot)
	bot.command(:help) do |event|
		event.channel.send_embed("") do |embed|
			create_help_embed(embed)
		end
	end
end

def create_help_embed(embed)
	embed.title = "List of Commands: (start with %)"
	embed.timestamp = Time.now
	spacer = "\uFEFF\n"

	embed.footer = Discordrb::Webhooks::EmbedFooter.new(
		text: "Made by Nishant Arora", 
		icon_url: "https://brand.umd.edu/img/New_UMD_Globe.png"
	)

	embed.add_field(
		name: spacer + "stock <symbol> OR stock <name>",
		value: "Finds stock data by stock symbol or company name.",
		inline: false
	)

	embed.add_field(
		name: spacer + "weather <zip_code>",
		value: "Finds weather data by zip code.",
		inline: false
	)

	embed.add_field(
		name: spacer + "fn <platform> <username>",
		value: "Finds fortnite statistics by platform and username.",
		inline: false
	)

	embed.add_field(
		name: spacer + "fn shop",
		value: "Gets all items in the item shop (pics coming soon).",
		inline: false
	)
end
