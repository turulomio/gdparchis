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

func squares_to_move():
	return self.last_throw()
