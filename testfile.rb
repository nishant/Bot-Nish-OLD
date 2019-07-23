require 'rspotify'
RSpotify.authenticate("074727fff09d40158c17fd964d0e6421", "e43a9934cc2d4421b462d535105cf7dc")
playlist = RSpotify::Playlist.find('', "0y4TYnGWwtlZbKJmHvzcIV")

strs = []
	
playlist.tracks.each do |track|
	artists = track.artists.map { |x| x.name}
	strs << 'p!play ' + track.name + ' : ' + artists.join(', ')
end
# puts playlist.tracks.size
puts strs.shuffle.join("\n")