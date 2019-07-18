
def process_spotify(bot)
	bot.command(:spotify) do |event|
		msg = event.message.content.split() 

		playlist_id = msg[1].sub("spotify:playlist:", "")
		shuffle = (msg.size == 3 && msg[2] == 'shuffle' ? true : false)

		RSpotify.authenticate(get_spotify_id(), get_spotify_secret())
		playlist = RSpotify::Playlist.find('', playlist_id)

		strs = []
	
		playlist.tracks.each do |track|
			artists = track.artists.map { |x| x.name}
			strs << 'p!play ' + track.name + ' : ' + artists.join(', ')
		end

		strs.shuffle! if shuffle == true
			
		event.respond strs.join('\n')

		event.respond "Added #{playlist.tracks.size} tracks to the queue."
	end	
end