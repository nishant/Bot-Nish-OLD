PASS_LEN = 16.freeze
ASCII_START = 33.freeze
ASCII_END = 126.freeze

def process_generate(bot)
	bot.command(:gen) do |event|
		if event.message.content.split(' ')[1] == 'pass'
			process_password(event)
		elsif event.message.content.split(' ')[1] == 'team'
			process_team(event, event.message.content.split(" "))
		else
			event.respond "Invalid paramater Must be one of (pass, team)."
		end
	end
end

def team_gen(players, team_size)
	team_num = 1
	text = []

    players.shuffle.each_slice(team_size) do |team| 
		text << "Team #" + team_num.to_s + ": " + team.inspect.to_s
        team_num += 1
	end
	
	return text.join("\n")
end

# need to call team_gen with event in process team

def process_team(event, msg)
	members = msg[2]
	team_size = msg[3].to_i

	players = members.split(',')
	
	event.respond team_gen(players, team_size)
end

def process_password(event)
	event.respond("Password sent in direct message.")
	event.user.pm(generate("", Random.new))
end

def generate(password, rng)
    PASS_LEN.times do 
        password << rng.rand(ASCII_START..ASCII_END).chr
    end

    password.split("").shuffle!.join
end