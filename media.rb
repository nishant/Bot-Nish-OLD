def process_spotify(bot)
	bot.command(:spotify) do |event|
		msg = event.message.content.split() 

		playlist_id = msg[1].sub("spotify:playlist:", "")
		shuffle = (msg.size == 3 && msg[2] == 'shuffle' ? true : false)

		puts "I MADE IT HERE"
		RSpotify.authenticate(get_spotify_id(), get_spotify_secret())
		playlist = RSpotify::Playlist.find('', playlist_id)

		strs = []
	
		i = 0
		playlist.tracks.each do |track|
			break if i == 5 
			artists = track.artists.map { |x| x.name}
			strs << 'p!play ' + track.name + ' : ' + artists.join(', ')
			i += 1
		end

		strs.shuffle! if shuffle == true
			
		strs.each do |str|
			event.respond str
		end

		event.respond "Added #{playlist.tracks.size} tracks to the queue."
	end	
end