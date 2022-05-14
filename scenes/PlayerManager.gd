class_name PlayerManager

extends DictionaryManager

var max_players=0

var current=null
var assistant

func _init (number):
	self.max_players=number
	for i in range(self.max_players):
		self.append(Player.new(i))
		
func set_assistant(_assistant):
	self.assistant=_assistant

func change_current_player():
	if self.current==null:
		self.current= self.d["0"]
	elif self.current==self.d["0"]:
		self.current = self.d["1"]
	elif self.current==d["1"]:
		self.current = self.d["2"]
	elif self.current==d["2"]:
		self.current = self.d["3"]
	elif self.current==d["3"]:
		self.current = self.d["0"]
	self.assistant.set_color(Globals.colorn(self.current.id))
	self.current.can_move_dice=true
	self.current.can_move_pieces=false
	self.current.dice_throws=[]
	self.current.dice.value=null
	self.current.dice.set_physics_process(true)
