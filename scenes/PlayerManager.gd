class_name PlayerManager

extends DictionaryManager

var max_players=0

var current=null
var assistant

func _init (number):
	self.max_players=number
		
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
		
	if self.current.plays==false:
		self.change_current_player()
		
	self.assistant.set_color(Globals.colorn(self.current.id))
	self.current.can_move_pieces=false
	self.current.dice_throws=[]
	self.current.dice.prepare_to_launch()
	if self.current.ia==true:
		self.current.dice.on_clicked()
	self.current.extra_moves=[]
	Globals.save_game(self.current.game)
	
