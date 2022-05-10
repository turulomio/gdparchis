class_name PlayerManager

extends DictionaryManager

var max_players=0

func _init (number):
	self.max_players=number
	for i in range(self.max_players):
		self.append(Player.new(i))
