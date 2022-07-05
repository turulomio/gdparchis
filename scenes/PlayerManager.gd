class_name PlayerManager

extends DictionaryManager

var max_players=0

var current=null

func _init (number):
	self.max_players=number
	
## Retiurns a list of players that play
func players_that_play():
	var r=[]
	for p in self.values():
		if p.plays==true:
			r.append(p)
	return r


func change_current_player():
	if self.current==null:
		self.current= self.d["0"]
	elif self.current==self.d["0"]:
		self.current = self.d["1"]
	elif self.current==self.d["1"]:
		self.current = self.d["2"]
	elif self.current==self.d["2"]:
		self.current = self.d["3"]
	elif self.current==self.d["3"]:
		self.current = self.d["0"]
		
	print("Current player now is ", self.current.name)
		
	if self.current.plays==false:
		self.change_current_player()
		return
		
	self.current.last_piece_moved=null
	self.current.can_move_pieces=false
	self.current.dice_throws=[]
	self.current.extra_moves=[]
	self.current.can_throw_dice=true
	if self.current.ia==true:
		self.current.dice.on_clicked()
	else:#Not ia
		print(self.current.game)
		Globals.save_game(self.current.game)
		if Globals.settings.get("automatic",true)==true:
			self.current.dice.on_clicked()
	
