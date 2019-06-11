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
		icon_url: "https://upload.wikimedia.org/wikipedia/en/thumb/3/3e/University_of_Maryland_seal.svg/1200px-University_of_Maryland_seal.svg.png"
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

	embed.add_field(
		name: spacer + "math <expr> OR math <func>(<list>)",
		value: "Evaluates mathematical expressions.
				Supported operators: +  -  *  /  %  ^  |  &  <  >  <=  >=  !=  =,
				Supported functions: min, max, sum, avg, count, round \(up/down\)",
		inline: false
	)

	embed.add_field(
		name: spacer + "ygo find <keyword> OR ygo <exact_card_name>",
		value: "Finds and retrieves Yugioh card info based on properly spelled/capitalized card name.
				Use the find command to get a list of all cards with <keyword> in the name.
				Use this result to lookup card info based with it's exact name.",
		inline: false
	)
end
