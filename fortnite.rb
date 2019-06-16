def process_fn(bot)
	bot.command(:fn) do |event|
		cmd = event.message.content.split(' ')[1]
		fn_shop(event) if cmd == 'shop'
		fn_drop(event) if cmd == 'drop'
		fn_stats(event) if (cmd == 'xbl' || cmd == 'pc' || cmd == 'psn')
	end
end

def fn_drop(event)
	event.channel.send_embed("") do |embed|
		create_drop_embed(embed)
    end
end

def create_drop_embed(embed)
	all_locations = [
        "Junk Junction", "Haunted Hills", "The Block",
        "Pleasant Park", "Snobby Shores", "Loot Lake",
        "Neo Tilted", "Shifty Shafts", "Polar Peak",
        "Frosty Flights", "Happy Hamlet", "Lucky Landing",
        "Fatal Fields", "Salty Springs", "Dusty Divot",
        "Paradise Palms", "Mega Mall", "Lonely Lodge",
        "Sunny Steps", "Lazy Lagoon", "Pueblito",
        "Viking Village", "Greasy Lake",
        "Gus", "Pressure Plant"
    ]

    common_locations = [
        "Pleasant Park", "Dusty Divot", "Salty Springs",
        "Paradise Palms", "Shifty Shafts", "Pueblito", "Viking Village"
	]

	embed.title = "Drop Location:"
	
	idx = rand((0...all_locations.size))
	embed.add_field(
		name: "From All Possible Drops:",
		value: "    " + all_locations.shuffle[idx] + "\n",
		inline: false
	)

	idx = rand((0...common_locations.size))
	embed.add_field(
		name: "From Our Common Drops:",
		value: "    " + common_locations.shuffle[idx] + "\n\n",
		inline: false
	)
end

def get_stats_data(all_data, json)
	if all_data[:stats]["p2"] != nil
        all_data[:solo_overview] = build_fn_arr(
            all_data[:stats]["p2"], 
            ["trnRating", "top1", "kd", "winRatio", "matches", "kills", "kpg"],
            ["trn", "wins", "kd", "win_rate", "matches", "kills", "kpg"]
        )
    end

    if all_data[:stats]["p10"] != nil
        all_data[:duo_overview] = build_fn_arr(
            all_data[:stats]["p10"],
            ["trnRating", "top1", "kd", "winRatio", "matches", "kills", "kpg"],
            ["trn", "wins", "kd", "win_rate", "matches", "kills", "kpg"]
        )
    end

    if all_data[:stats]["p9"] != nil
        all_data[:squad_overview] = build_fn_arr(
            all_data[:stats]["p9"],
            ["trnRating", "top1", "kd", "winRatio", "matches", "kills", "kpg"],
            ["trn", "wins", "kd", "win_rate", "matches", "kills", "kpg"]
        )
    end

    if all_data[:stats]["curr_p2"] != nil
        all_data[:season_solo] = build_fn_arr(
            all_data[:stats]["curr_p2"],
            ["trnRating", "top1", "kd", "winRatio", "matches", "kills", "kpg"],
            ["trn", "wins", "kd", "win_rate", "matches", "kills", "kpg"]
        )
    end

    if all_data[:stats]["curr_p10"] != nil
        all_data[:season_duo] = build_fn_arr(
            all_data[:stats]["curr_p10"],
            ["trnRating", "top1", "kd", "winRatio", "matches", "kills", "kpg"],
            ["trn", "wins", "kd", "win_rate", "matches", "kills", "kpg"]
        )
    end

    if all_data[:stats]["curr_p9"] != nil
        all_data[:season_squad] = build_fn_arr(
            all_data[:stats]["curr_p9"],
            ["trnRating", "top1", "kd", "winRatio", "matches", "kills", "kpg"],
            ["trn", "wins", "kd", "win_rate", "matches", "kills", "kpg"]
        )
    end

    if json["lifeTimeStats"] != nil
        all_data[:lifetime] = build_fn_arr(
            json["lifeTimeStats"],
            [7, 8, 9, 10, 11],
            ["matches", "wins", "win_rate", "kills", "kd"]
        )
    end
end

def fn_stats(event)
	all_data = {}
    all_data[:platform] = event.message.content.split(' ')[1]
    all_data[:username] = event.message.content.split(' ')[2..-1].join(" ")
    
    url = URI.encode("https://api.fortnitetracker.com/v1/profile/#{all_data[:platform]}/#{all_data[:username]}/")
    headers = {"TRN-Api-Key": get_fn_api_key()}
    response = HTTParty.get(url, headers: headers)

    json = JSON.parse(response.body)
    all_data[:stats] = json["stats"]

	all_data[:lifetime] = {}
	all_data[:solo_overview] = {}
	all_data[:duo_overview] = {}
	all_data[:squad_overview] = {}
	all_data[:season_solo] = {}
	all_data[:season_duo] = {}
	all_data[:season_squad] = {}

	get_stats_data(all_data, json)
	
    event.channel.send_embed("") do |embed|
        create_stats_embed(embed, all_data)
    end
end

def create_stats_embed(embed, all_data)
	embed.title = "Fortnite Statistics for #{all_data[:username]}"
	embed.url = URI.encode("https://fortnitetracker.com/profile/#{all_data[:platform]}/#{all_data[:username]}/")
	embed.timestamp = Time.now
	
	embed.footer = Discordrb::Webhooks::EmbedFooter.new(
		text: "Data from Fortnite Tracker", 
		icon_url: "https://img.icons8.com/color/420/fortnite.png"
	)

	if all_data[:stats]["p2"] == nil && all_data[:stats]["p10"] == nil && all_data[:stats]["p9"] == nil
		embed.add_field(
			name: "Lifetime Overview",
			value:  "Wins ........................ 0" + "\n" +
					"Kills .......................... 0" + "\n" +
					"K/D .......................... 0" + "\n" +
					"Win Rate ................. 0" + "\n" +
					"Matches .................. 0" + "\n",
			inline: true
		)
	else
		embed.add_field(
			name: "Lifetime Overview",
			value:  "Wins ........................ " + all_data[:lifetime]["wins"] + "\n" +
					"Kills .......................... " + all_data[:lifetime]["kills"] + "\n" +
					"K/D .......................... " + all_data[:lifetime]["kd"] + "\n" +
					"Win Rate ................. " + all_data[:lifetime]["win_rate"] + "\n" +
					"Matches .................. " + all_data[:lifetime]["matches"] + "\n",
			inline: true
		)
	end

	season_solo = all_data[:season_solo]
	season_duo = all_data[:season_duo]
	season_squad = all_data[:season_squad]

	season_wins = (season_solo["wins"].to_i + season_duo["wins"].to_i + season_squad["wins"].to_i).to_s
	season_matches = (season_solo["matches"].to_i + season_duo["matches"].to_i + season_squad["matches"].to_i).to_s
	season_win_rate = (100 * (season_wins.to_f / season_matches.to_f)).ceil(2).to_s
	season_kills = (season_solo["kills"].to_i + season_duo["kills"].to_i + season_squad["kills"].to_i).to_s
	season_kd = (season_kills.to_f / (season_matches.to_f - season_wins.to_f)).ceil(2).to_s

	if all_data[:stats]["curr_p2"] == nil && all_data[:stats]["curr_p10"] == nil && all_data[:stats]["curr_pp9"] == nil
		embed.add_field(
			name: "Season Overview",
			value:  "Wins ........................ 0" + "\n" +
					"Kills .......................... 0" + "\n" +
					"K/D .......................... 0" + "\n" +
					"Win Rate ................. 0" + "%\n" +
					"Matches .................. 0" + "\n",
			inline: true
		)
	else
		embed.add_field(
			name: "Season Overview",
			value:  "Wins ........................ " + season_wins + "\n" +
					"Kills .......................... " + season_kills + "\n" +
					"K/D .......................... " + season_kd + "\n" +
					"Win Rate ................. " + season_win_rate + "%\n" +
					"Matches .................. " + season_matches + "\n",
			inline: true
		)
	end

	embed.add_field(
		name: "\uFEFF",
		value:  "\uFEFF",
		inline: true
	)

	if all_data[:stats]["p2"] == nil
		embed.add_field(
			name: "Lifetime Solos",
			value:  "Wins ......................... 0" + "\n" +
					"Kills ........................... 0" + "\n" +
					"K/D ........................... 0" + "\n" +
					"Win Rate .................. 0" + "%\n" +
					"Matches ................... 0" + "\n" +
					"Kills Per Match ....... 0" + "\n",
			inline: true
		)
	else
		embed.add_field(
			name: "Lifetime Solos",
			value:  "Wins ......................... " + all_data[:solo_overview]["wins"] + "\n" +
					"Kills ........................... " + all_data[:solo_overview]["kills"] + "\n" +
					"K/D ........................... " + all_data[:solo_overview]["kd"] + "\n" +
					"Win Rate .................. " + all_data[:solo_overview]["win_rate"] + "%\n" +
					"Matches ................... " + all_data[:solo_overview]["matches"] + "\n" +
					"Kills Per Match ....... " + all_data[:solo_overview]["kpg"] + "\n",
			inline: true
		)
	end

	if all_data[:stats]["curr_p2"] == nil
		embed.add_field(
			name: "Season Solos",
			value:  "Wins ......................... 0" + "\n" +
			"Kills ........................... 0" + "\n" +
			"K/D ........................... 0" + "\n" +
			"Win Rate .................. 0" + "%\n" +
			"Matches ................... 0" + "\n" +
			"Kills Per Match ....... 0" + "\n" +
			"TRN ........................... DNE" + "\n",
			inline: true
		)
	else
		embed.add_field(
			name: "Season Solos",
			value:  "Wins ......................... " + season_solo["wins"] + "\n" +
					"Kills ........................... " + season_solo["kills"] + "\n" +
					"K/D ........................... " + season_solo["kd"] + "\n" +
					"Win Rate .................. " + season_solo["win_rate"] + "%\n" +
					"Matches ................... " + season_solo["matches"] + "\n" +
					"Kills Per Match ....... " + season_solo["kpg"] + "\n" +
					"TRN ........................... " + season_solo["trn"] + "\n",
			inline: true
		)
	end
	
	embed.add_field(
		name: "\uFEFF",
		value:  "\uFEFF",
		inline: true
	)

	if all_data[:stats]["p10"] == nil
		embed.add_field(
			name: "Lifetime Duos",
			value:  "Wins ......................... 0" + "\n" +
					"Kills ........................... 0" + "\n" +
					"K/D ........................... 0" + "\n" +
					"Win Rate .................. 0" + "%\n" +
					"Matches ................... 0" + "\n" +
					"Kills Per Match ....... 0" + "\n",
			inline: true
		)
	else
		embed.add_field(
			name: "Lifetime Duos",
			value:  "Wins ......................... " + all_data[:duo_overview]["wins"] + "\n" +
					"Kills ........................... " + all_data[:duo_overview]["kills"] + "\n" +
					"K/D ........................... " + all_data[:duo_overview]["kd"] + "\n" +
					"Win Rate .................. " + all_data[:duo_overview]["win_rate"] + "%\n" +
					"Matches ................... " + all_data[:duo_overview]["matches"] + "\n" +
					"Kills Per Match ....... " + all_data[:duo_overview]["kpg"] + "\n",
			inline: true
		)
	end

	if all_data[:stats]["curr_p10"] == nil
		embed.add_field(
			name: "Season Duos",
			value:  "Wins ......................... 0" + "\n" +
					"Kills ........................... 0" + "\n" +
					"K/D ........................... 0" + "\n" +
					"Win Rate .................. 0" + "%\n" +
					"Matches ................... 0" + "\n" +
					"Kills Per Match ....... 0" + "\n" +
					"TRN ........................... 0" + "\n",
			inline: true
		)
	else
		embed.add_field(
			name: "Season Duos",
			value:  "Wins ......................... " + season_duo["wins"] + "\n" +
					"Kills ........................... " + season_duo["kills"] + "\n" +
					"K/D ........................... " + season_duo["kd"] + "\n" +
					"Win Rate .................. " + season_duo["win_rate"] + "%\n" +
					"Matches ................... " + season_duo["matches"] + "\n" +
					"Kills Per Match ....... " + season_duo["kpg"] + "\n" +
					"TRN ........................... " + season_duo["trn"] + "\n",
			inline: true
		)
	end

	embed.add_field(
		name: "\uFEFF",
		value:  "\uFEFF",
		inline: true
	)

	if all_data[:stats]["p9"] == nil
		embed.add_field(
			name: "Lifetime Squads",
			value:  "Wins ......................... 0" + "\n" +
					"Kills ........................... 0" + "\n" +
					"K/D ........................... 0" + "\n" +
					"Win Rate .................. 0" + "%\n" +
					"Matches ................... 0" + "\n" +
					"Kills Per Match ....... 0" + "\n",
			inline: true
		)
	else
		embed.add_field(
			name: "Lifetime Squads",
			value:  "Wins ......................... " + all_data[:squad_overview]["wins"] + "\n" +
					"Kills ........................... " + all_data[:squad_overview]["kills"] + "\n" +
					"K/D ........................... " + all_data[:squad_overview]["kd"] + "\n" +
					"Win Rate .................. " + all_data[:squad_overview]["win_rate"] + "%\n" +
					"Matches ................... " + all_data[:squad_overview]["matches"] + "\n" +
					"Kills Per Match ....... " + all_data[:squad_overview]["kpg"] + "\n",
			inline: true
		)
	end
	
	if all_data[:stats]["curr_p9"] == nil
		embed.add_field(
			name: "Season Squads",
			value:  "Wins ......................... 0" + "\n" +
					"Kills ........................... 0" + "\n" +
					"K/D ........................... 0" + "\n" +
					"Win Rate .................. 0" + "%\n" +
					"Matches ................... 0" + "\n" +
					"Kills Per Match ....... 0" + "\n" +
					"TRN ........................... 0" + "\n",
			inline: true
		)
	else
		embed.add_field(
			name: "Season Squads",
			value:  "Wins ......................... " + season_squad["wins"] + "\n" +
					"Kills ........................... " + season_squad["kills"] + "\n" +
					"K/D ........................... " + season_squad["kd"] + "\n" +
					"Win Rate .................. " + season_squad["win_rate"] + "%\n" +
					"Matches ................... " + season_squad["matches"] + "\n" +
					"Kills Per Match ....... " + season_squad["kpg"] + "\n" +
					"TRN ........................... " + season_squad["trn"] + "\n",
			inline: true
		)
	end

	embed.add_field(
		name: "\uFEFF",
		value:  "\uFEFF",
		inline: true
	)
end

def get_shop_data(items, temp)
	# num items in shop is not constant, loop to get all
    items.each_with_index do |item, idx|
        item.delete("manifestId")
        item.delete("storeCategory")
        item.delete("rarity")
        temp[idx] = item
    end
    
    return items = temp
end

def fn_shop(event)
    url = URI.encode("https://api.fortnitetracker.com/v1/store/")
    headers = {"TRN-Api-Key": get_fn_api_key()}
    response = HTTParty.get(url, headers: headers)

    items = JSON.parse(response.body)
    temp = {}

	items = get_shop_data(items, temp)

	event.channel.send_embed("") do |embed|
		create_shop_embed(embed, items)
    end

	# download_shop_images(items)
end

def download_image(url, dest)
    open(url) do |u|
        File.open(dest, 'wb') { |f| f.write(u.read) }
    end
end

def download_shop_images(items)
	urls = []
	
    items.each do |k,v|
        urls << v["imageUrl"]
	end
	
	urls.each { |url| download_image(url, url.split('/').last) }
end

def create_shop_embed(embed, items)
	embed.title = "Current Fortnite Item Shop"
	embed.url = URI.encode("https://fnbr.co/shop")
	embed.timestamp = Time.now
	
	embed.footer = Discordrb::Webhooks::EmbedFooter.new(
		text: "Data from Fortnite Tracker & FNBR", 
		icon_url: "https://image.fnbr.co/price/icon_vbucks_50x.png"
	)

	items.each do |k,v|
		embed.add_field(
			name: v["name"],
			value: v["vBucks"].to_s + " vBucks",
			inline: true
		)
	end
end
		
def build_fn_arr(base, source_keys, dst_keys)
    output = {}

    for i in 0..(source_keys.length - 1) do
        output[dst_keys[i]] = base[source_keys[i]]["value"]
    end
    
    return output
end

def add_spacer(embed)
	embed.add_field(
		name: "\uFEFF",
		value:  "\uFEFF",
		inline: true
	)
end