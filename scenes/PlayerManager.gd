class_name PlayerManager

extends DictionaryManager

var max_players=0

var current=null
var assistant

func _init (number):
	self.max_players=number
	for i in range(self.max_players):
		self.append(Player.new(i))
		
func set_assistant(assistant):
	self.assistant=assistant

func change_current_player():
	if current==null:
		return self.d["0"]
	if current==d["0"]:
		return self.d["1"]
	if current==d["1"]:
		return self.d["2"]
	if current==d["2"]:
		return self.d["3"]
	if current==d["3"]:
		return self.d["0"]
	self.assistant.set_color(self.current.id)
