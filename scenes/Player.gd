class_name Player
var id : int = 0
var name_internal : String
var name : String
var color
var e_color
var active : bool
var pieces=[]
var route: Route
var dice: Dice
var game
var can_move_dice: bool = false
var can_move_pieces: bool = false
var dice_throws=[]
var extra_moves=[]
var last_piece_moved=null


func _init(node_id):
	self.id=node_id
	self.e_color=node_id

	match(self.id):
		0:
			self.name_internal="yellow"
			self.name="Yellowy"
			self.active=true
		1:
			self.name_internal="blue"
			self.name="Bluey"
			self.active=true
		2:
			self.name_internal="red"
			self.name="Redy"
			self.active=true
		3:
			self.name_internal="green"
			self.name="Greeny"
			self.active=true

func _to_string():
	return "[Player: "+ str(self.id) + "]"

func append_piece(o):
	self.pieces.append(o)

func set_route(p):
	self.route=p

func set_game(g):
	self.game=g
	
func set_dice(d):
	self.dice=d
	
func last_throw():
	return self.dice_throws[self.dice_throws.size()-1]

## Returns if player is game current player
func is_current():
	if self == self.game.players.current:
		return true
	return false
	
func last_throw_was_a_six():
	if self.dice_throws[self.dice_throws.size()-1]==6 and self.dice_throws.size()<3:
		return true
	return false
	
func dice_throws_has_three_sixes():
	if self.dice_throws.size()==3 and self.dice_throws[0]==6 and self.dice_throws[1]==6 and self.dice_throws[2]==6:
		return true
	return false
	
func can_move_other_piece():
	return false
	
func can_move_dice_again():
	if self.last_throw_was_a_six():
		return true
	return false
	
func are_all_pieces_out_of_home():
	for p in self.pieces:
		if p.route_position==0:
			return false
	return true

func can_some_piece_move():
	for p in self.pieces:
		if p.can_move_to_route_position(p.route_position+p.squares_to_move()):
			return true
	return false
	
