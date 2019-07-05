# def process_media(bot)
# 	bot.command(:play) do |event|
# 		playlist_indo = {}
    
# 		url = URI.encode("https://api.fortnitetracker.com/v1/profile/#{all_data[:platform]}/#{all_data[:username]}/")
# 		headers = {"TRN-Api-Key": get_fn_api_key()}
# 		response = HTTParty.get(url, headers: headers)

# 		json = JSON.parse(response.body)
# 		all_data[:stats] = json["stats"]
		
# 		event.channel.send_embed("") do |embed|
# 			create_media_embed(embed)
# 		end
# 	end
# end

# def create_media_embed(embed)