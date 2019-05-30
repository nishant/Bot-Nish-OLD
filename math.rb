
def process_math(bot)
	calculator = Dentaku::Calculator.new

	bot.command(:math) do |event|
		expr = event.message.content.sub("%math", "")
		event.respond calculator.evaluate(expr)
	end
end

