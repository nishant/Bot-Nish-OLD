require 'open-uri'

def process_media(bot)
	bot.command(:mp) do |event|
		if event.message.content.split(' ')[1] == 'play'
			query = event.message.content.sub("%mp play ", "")
			play_media(event, query)
		elsif event.message.content.split(' ')[1] == 'stop'
			stop_media(event)
		else
			event.respond "More commands coming soon."
		end
	end
end

def play_media(event, query)
	voice_channel = event.user.voice_channel

	if voice_channel == nil
		event.respond "You need to be in a voice channel to play media."
	else 
		event.bot.voice_connect(voice_channel)
	

		api_key = get_youtube_api_key()
		request = "https://www.googleapis.com/youtube/v3/search?part=snippet&q=#{query}&type=video&key=#{api_key}"
		response = open(request).readlines.join
		results = JSON.parse(response)

		url = "https://www.youtube.com/watch?v=" + results["items"][0]["id"]["videoId"]

		dir = "./media/"
		num_file = Dir[File.join(dir, '**', '*')].count { |file| File.file?(file) } + 1

		system("youtube-dl -f 'bestaudio' --buffer-size 16K -o ./media/file#{num_file} --audio-quality 0 #{url}")
		
		event.respond "Playing #{url}"

		event.voice.adjust_average = true
		event.voice.adjust_interval = 150

		event.voice.play_file("./media/file#{num_file}")

		system("rm ./media/file#{num_file}")

		if event.voice != nil
			event.voice.destroy
		end
	end
end

def stop_media(event)
	system("rm -r ./media/*")
	if event.voice != nil
		event.voice.destroy
	end
end

