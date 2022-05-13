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
	print("Before",self.current)
	if current==null:
		self.current= self.d["0"]
	else:
		self.current.can_move_pieces=false
	if current==d["0"]:
		self.current = self.d["1"]
	if current==d["1"]:
		self.current = self.d["2"]
	if current==d["2"]:
		self.current = self.d["3"]
	if current==d["3"]:
		self.current = self.d["0"]
	print("Afterr",self.current)
	self.assistant.set_color(Globals.colorn(self.current.id))
	self.current.can_move_dice=true
	self.current.can_move_pieces=false
	self.current.dice_throws=[]
	print("After can",self.current.can_move_dice,self.current.can_move_pieces)
