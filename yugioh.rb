request = "https://db.ygoprodeck.com/api/v4/cardinfo.php"
response = open(request).readlines.join
$card_catalog = JSON.parse(response)

def process_yugioh(bot)
	bot.command(:ygo) do |event|
		if event.message.content.split(' ')[1] == 'find'
			keyword = event.message.content.sub("%ygo find ", "")
			ygo_find(event, keyword)
		else
			ygo(event)
		end
	end
end

def ygo_find(event, keyword)
	request = "https://db.ygoprodeck.com/api/v4/cardinfo.php?fname=#{keyword}"
	response = open(request).readlines.join
	cards = JSON.parse(response)
	names = []

	cards[0].each do |card|
		names << card["name"]
	end

	names.sort!.uniq!

	total_chars = names.join("\n").length

	if total_chars <= 2000
		event.respond names.join("\n")
	else
		while total_chars > 0  do
			msg = ""
			names.each do |name|
				if 2000 - msg.length - name.length > 0
					msg += name + "\n"
				end
			end
			total_chars -= msg.length
			event.respond msg
		end
	end
end

def ygo(event)
	card = event.message.content.sub("%ygo ", "")

	event.channel.send_embed("") do |embed|
		create_ygo_embed(embed, card)
	end

	send_card_image(event, card)
end

def get_card_idx(card)
	$card_catalog[0].each_with_index do |data, idx| 
		if data["name"] == card
			return idx
		end
	end
end

def send_card_image(event, card)
	idx = get_card_idx(card)
	data = $card_catalog[0][idx]

	event.channel.send_embed("") do |embed|
		embed.image = Discordrb::Webhooks::EmbedImage.new(
			url: data["image_url"]
		)
	end

end

# TRAP:  name type desc race image_url archetype?
# SPELL: name type desc race image_url archetype?
# MONSTER: name type desc atk def level race attribute image_url archetype? 
def create_ygo_embed(embed, card)
	embed.title = "Card Info:"
	embed.timestamp = Time.now

	embed.footer = Discordrb::Webhooks::EmbedFooter.new(
		text: "YGOPRODECK", 
		icon_url: "http://pluspng.com/img-png/yugioh-png-file-official-yu-gi-oh-logo-png-500.png"
	)

	idx = get_card_idx(card)
	data = $card_catalog[0][idx]

	if ["Spell Card", "Trap Card"].include?(data["type"])
		embed.add_field(
			name: "Name:",
			value: "```#{data["name"]}```",
			inline: true
		)

		embed.add_field(
			name: "Card Type:",
			value: "```#{data["type"]}```",
			inline: true
		)

		embed.add_field(
			name: "#{data["type"].split(' ')[0]} Type:",
			value: "```#{data["race"]}```",
			inline: true
		)
		
		if data["archetype"] != nil
			embed.add_field(
				name: "Archetype:",
				value: "```#{data["archetype"]}```",
				inline: true
			)
		end
		
		embed.add_field(
			name: "Description:",
			value: "```#{data["desc"]}```",
			inline: true
		)
	else
		embed.add_field(
			name: "Name:",
			value: "```#{data["name"]}```",
			inline: true
		)

		embed.add_field(
			name: "Card Type:",
			value: "```#{data["type"]}```",
			inline: true
		)

		attribute = data["attribute"].chars
		attribute = [attribute[0]] << attribute[1..-1].map(&:downcase)

		embed.add_field(
			name: "Attribute:",
			value: "```#{attribute.join("")}```",
			inline: true
		)

		embed.add_field(
			name: "Monster Type:",
			value: "```#{data["race"]}```",
			inline: true
		)
		
		if data["archetype"] != nil
			embed.add_field(
				name: "Archetype:",
				value: "```#{data["archetype"]}```",
				inline: true
			)
		else 
			embed.add_field(
				name: "Archetype:",
				value: "```-----```",
				inline: true
			)
		end

		embed.add_field(
			name: "Attack:",
			value: "```#{data["atk"]}```",
			inline: true
		)
		embed.add_field(
			name: "Defense:",
			value: "```#{data["def"]}```",
			inline: true
		)
		embed.add_field(
			name: "Level:",
			value: "```#{data["level"]}```",
			inline: true
		)

		embed.add_field(
			name: "Description:",
			value: "```#{data["desc"]}```",
			inline: true
		)
	end
end

def add_spacer(embed)
	embed.add_field(
		name: "\uFEFF",
		value:  "\uFEFF",
		inline: true
	)
end