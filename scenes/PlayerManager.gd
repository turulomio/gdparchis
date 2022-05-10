class_name PlayerManager

extends DictionaryManager


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var max_players=0

func _init (number):
	self.max_players=number
	for i in range(self.max_players):
		self.append(Player.new(i))
	
	print(self.d)
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
