require 'discordrb'
require 'open-uri'
require 'json'
require 'psych'
require 'httparty'

bot = Discordrb::Commands::CommandBot.new(
    token: 'NTgxOTA5OTM3MTY5NjI5MTk1.XOmOyA.6obFYsF1bBd2_KNiXALvSXqNG7g',
    client_id: 359082109119365140,
    prefix: '%'
)

bot.command(:help) do |event|
    to_print = []

    to_print << 'Command List (begin with %):'
    to_print << 'ping - a test command to check if bot is up'
    to_print << 'marco - where\'s polo?'
    to_print << 'sum <num1 num2 ...> - sums a space-separated list of numbers'
    to_print << 'weather <zip code> - gets weather for a specified zip code'

    event.respond to_print.join("\n")
end

bot.message(with_text: 'ping') do |event|
  event.respond 'pong'
end

bot.message(with_text: 'marco') do |event|
    event.respond 'polo'
end

bot.command(:sum) do |event|
    numbers = event.message.content.split(' ')
    event.respond numbers.map(&:to_i).reduce(0, :+)
end

def kelvin_to_fahrenheit(value)
    return (((value.to_f - 273) * 9 / 5) + 32).ceil(2)
end

bot.command(:weather) do |event|
    api_key = '5be3960bf306ce17c9c742f07c351972'
    zip = event.message.content.split(' ')[1]
    request = "http://api.openweathermap.org/data/2.5/weather?zip=#{zip}&APPID=#{api_key}"
    response = open(request).readlines.join
    weather_data = JSON.parse(response)

    event.channel.send_embed("") do |embed|
        embed.title = "Weather Data for #{zip}"
        embed.url = URI.encode("https://www.google.com/search?q=weather+#{zip}")
        embed.timestamp = Time.now
        
        embed.footer = Discordrb::Webhooks::EmbedFooter.new(
            text: "Open Weather Map", 
            icon_url: "https://cdn1.iconfinder.com/data/icons/weather-elements/512/Weather_SunAbstract.png"
        )

        embed.add_field(
            name: "\uFEFF",
            value:  "Location: ..................... " + weather_data["name"].to_s.downcase + "\n" +
                    "Temperature: ............. " + kelvin_to_fahrenheit(weather_data["main"]["temp"]).to_s + ' °F' + "\n" +
                    "Weather: ..................... " + weather_data["weather"][0]["main"].to_s.downcase + "\n" +
                    "Description: ................ " + weather_data["weather"][0]["description"].to_s + "\n" +
                    "Humidity: .................... " + weather_data["main"]["humidity"].to_s + '%' + "\n" +
                    "Low: .............................. " + kelvin_to_fahrenheit(weather_data["main"]["temp_min"]).to_s + ' °F' + "\n" +
                    "High: ............................. " + kelvin_to_fahrenheit(weather_data["main"]["temp_max"]).to_s + ' °F' + "\n" +
                    "Wind: ........................... " + weather_data["wind"]["speed"].to_s + " mph" + "\n" +
                    "Sunrise: ........................ " + Time.at((weather_data["sys"]["sunrise"].to_f)).strftime("%l:%M %p").to_s.lstrip() + "\n" +
                    "Sunset: ......................... " + Time.at((weather_data["sys"]["sunset"].to_f)).strftime("%l:%M %p").to_s.lstrip() + "\n",
            inline: true
        )
    end
end

bot.command(:stock) do |event|
    api_key = '3KT67VI8256BBOXC'
    keyword = event.message.content.sub("%stock", "")
    request = "https://www.alphavantage.co/query?function=SYMBOL_SEARCH&keywords=#{keyword}&apikey=#{api_key}"
    response = open(request).readlines.join
    search_data = JSON.parse(response)

    to_print = []
    to_print << "Company ...... " + search_data["bestMatches"][0]["2. name"]
    to_print << "Symbol .......... " + search_data["bestMatches"][0]["1. symbol"]

    symbol = search_data["bestMatches"][0]["1. symbol"]

    request = "https://www.alphavantage.co/query?function=TIME_SERIES_DAILY&symbol=#{symbol}&apikey=#{api_key}"
    response = open(request).readlines.join
    stock_data = JSON.parse(response)
    
    most_recent = stock_data["Meta Data"]["3. Last Refreshed"].split(' ')[0]

    info = stock_data["Time Series (Daily)"][most_recent]
    
    to_print << "Open .............. " + '%.2f' % info["1. open"].to_f.ceil(2)
    to_print << "Close .............. " + '%.2f' % info["4. close"].to_f.ceil(2).to_s
    to_print << "High ................ " + '%.2f' % info["2. high"].to_f.ceil(2).to_s
    to_print << "Low ................. " + '%.2f' % info["3. low"].to_f.ceil(2).to_s

    event.respond to_print.join("\n")
end

def build_fn_arr(base, source_keys, dst_keys)
    output = {}

    for i in 0..(source_keys.length - 1) do
        output[dst_keys[i]] = base[source_keys[i]]["value"]
    end
    
    return output
end

def fn_stats(event)
    platform = event.message.content.split(' ')[1]
    username = event.message.content.split(' ')[2..-1].join(" ")
    
    url = URI.encode("https://api.fortnitetracker.com/v1/profile/#{platform}/#{username}/")
    headers = {"TRN-Api-Key": "4e622ec4-f903-49ee-92b6-cbdf5c2c5488"}
    response = HTTParty.get(url, headers: headers)

    json = JSON.parse(response.body)
    stats = json["stats"]

    lifetime = {}
    solo_overview = duo_overview = squad_overview = {}
    season_solo = season_duo = season_squad = {}

    name = json["epicUserHandle"]

    if stats["p2"] != nil
        solo_overview = build_fn_arr(
            stats["p2"], 
            ["trnRating", "top1", "kd", "winRatio", "matches", "kills", "kpg"],
            ["trn", "wins", "kd", "win_rate", "matches", "kills", "kpg"]
        )
    end

    if stats["p10"] != nil
        duo_overview = build_fn_arr(
            stats["p10"],
            ["trnRating", "top1", "kd", "winRatio", "matches", "kills", "kpg"],
            ["trn", "wins", "kd", "win_rate", "matches", "kills", "kpg"]
        )
    end

    if stats["p9"] != nil
        squad_overview = build_fn_arr(
            stats["p9"],
            ["trnRating", "top1", "kd", "winRatio", "matches", "kills", "kpg"],
            ["trn", "wins", "kd", "win_rate", "matches", "kills", "kpg"]
        )
    end

    puts stats["curr_p2"]
    if stats["curr_p2"] != nil
        season_solo = build_fn_arr(
            stats["curr_p2"],
            ["trnRating", "top1", "kd", "winRatio", "matches", "kills", "kpg"],
            ["trn", "wins", "kd", "win_rate", "matches", "kills", "kpg"]
        )
    end

    if stats["curr_p10"] != nil
        season_duo = build_fn_arr(
            stats["curr_p10"],
            ["trnRating", "top1", "kd", "winRatio", "matches", "kills", "kpg"],
            ["trn", "wins", "kd", "win_rate", "matches", "kills", "kpg"]
        )
    end

    if stats["curr_p9"] != nil
        season_squad = build_fn_arr(
            stats["curr_p9"],
            ["trnRating", "top1", "kd", "winRatio", "matches", "kills", "kpg"],
            ["trn", "wins", "kd", "win_rate", "matches", "kills", "kpg"]
        )
    end

    if json["lifeTimeStats"] != nil
        lifetime = build_fn_arr(
            json["lifeTimeStats"],
            [7, 8, 9, 10, 11],
            ["matches", "wins", "win_rate", "kills", "kd"]
        )
    end

    event.channel.send_embed("") do |embed|
        embed.title = "Fortnite Statistics for #{name}"
        embed.url = URI.encode("https://fortnitetracker.com/profile/#{platform}/#{username}/")
        embed.timestamp = Time.now
        
        embed.footer = Discordrb::Webhooks::EmbedFooter.new(
            text: "Data from Fortnite Tracker", 
            icon_url: "https://img.icons8.com/color/420/fortnite.png"
        )

        embed.add_field(
            name: "Lifetime Overview",
            value:  "Wins ........................ " + lifetime["wins"] + "\n" +
                    "Kills .......................... " + lifetime["kills"] + "\n" +
                    "K/D .......................... " + lifetime["kd"] + "\n" +
                    "Win Rate ................. " + lifetime["win_rate"] + "\n" +
                    "Matches .................. " + lifetime["matches"] + "\n",
            inline: true
        )

        season_wins = (season_solo["wins"].to_i + season_duo["wins"].to_i + season_squad["wins"].to_i).to_s
        season_matches = (season_solo["matches"].to_i + season_duo["matches"].to_i + season_squad["matches"].to_i).to_s
        season_win_rate = (100 * (season_wins.to_f / season_matches.to_f)).ceil(2).to_s
        season_kills = (season_solo["kills"].to_i + season_duo["kills"].to_i + season_squad["kills"].to_i).to_s
        season_kd = (season_kills.to_f / (season_matches.to_f - season_wins.to_f)).ceil(2).to_s

        embed.add_field(
            name: "Season Overview",
            value:  "Wins ........................ " + season_wins + "\n" +
                    "Kills .......................... " + season_kills + "\n" +
                    "K/D .......................... " + season_kd + "\n" +
                    "Win Rate ................. " + season_win_rate + "%\n" +
                    "Matches .................. " + season_matches + "\n",
            inline: true
        )

        embed.add_field(
            name: "\uFEFF",
            value:  "\uFEFF",
            inline: true
        )

        embed.add_field(
            name: "Lifetime Solos",
            value:  "Wins ......................... " + solo_overview["wins"] + "\n" +
                    "Kills ........................... " + solo_overview["kills"] + "\n" +
                    "K/D ........................... " + solo_overview["kd"] + "\n" +
                    "Win Rate .................. " + solo_overview["win_rate"] + "%\n" +
                    "Matches ................... " + solo_overview["matches"] + "\n" +
                    "Kills Per Match ....... " + solo_overview["kpg"] + "\n",
            inline: true
        )

        if stats["curr_p2"] == nil
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

        embed.add_field(
            name: "Lifetime Duos",
            value:  "Wins ......................... " + duo_overview["wins"] + "\n" +
                    "Kills ........................... " + duo_overview["kills"] + "\n" +
                    "K/D ........................... " + duo_overview["kd"] + "\n" +
                    "Win Rate .................. " + duo_overview["win_rate"] + "%\n" +
                    "Matches ................... " + duo_overview["matches"] + "\n" +
                    "Kills Per Match ....... " + duo_overview["kpg"] + "\n",
            inline: true
        )

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

        embed.add_field(
            name: "\uFEFF",
            value:  "\uFEFF",
            inline: true
        )

        embed.add_field(
            name: "Lifetime Squads",
            value:  "Wins ......................... " + squad_overview["wins"] + "\n" +
                    "Kills ........................... " + squad_overview["kills"] + "\n" +
                    "K/D ........................... " + squad_overview["kd"] + "\n" +
                    "Win Rate .................. " + squad_overview["win_rate"] + "%\n" +
                    "Matches ................... " + squad_overview["matches"] + "\n" +
                    "Kills Per Match ....... " + squad_overview["kpg"] + "\n",
            inline: true
        )
       
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

        embed.add_field(
            name: "\uFEFF",
            value:  "\uFEFF",
            inline: true
        )
    end
end

def fn_shop(event)
    url = URI.encode("https://api.fortnitetracker.com/v1/store/")
    headers = {"TRN-Api-Key": "4e622ec4-f903-49ee-92b6-cbdf5c2c5488"}
    response = HTTParty.get(url, headers: headers)

    items = JSON.parse(response.body)
    temp = {}

    # num items in shop is not constant, loop to get all
    items.each_with_index do |item, idx|
        item.delete("manifestId")
        item.delete("storeCategory")
        item.delete("rarity")
        temp[idx] = item
    end
    
    items = temp

    event.channel.send_embed("") do |embed|
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

    urls = []
    items.each do |k,v|
        urls << v["imageUrl"]
    end
    urls.each { |url| download_image(url, url.split('/').last) }
end

def download_image(url, dest)
    open(url) do |u|
        File.open(dest, 'wb') { |f| f.write(u.read) }
    end
end

bot.command(:fn) do |event|
    if event.message.content.split(' ')[1] == 'shop'
        fn_shop(event)
    else
        fn_stats(event)
    end
end

bot.run

