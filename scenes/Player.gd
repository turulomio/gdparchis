class_name Player
var id : int
var name : String
var color
var e_color
var pieces=[]
var route: Route
var dice: Dice
var game
var can_move_dice: bool = false
var can_move_pieces: bool = false
var dice_throws=[]
var extra_moves=[]
var last_piece_moved=null
var plays=true
var ia=false


func _init(_id,_plays,_ia):
	self.id=_id
	self.e_color=_id
	self.plays=_plays
	self.ia=_ia

	match(self.id):
		0:
			self.name="Yellowy"
		1:
			self.name="Bluey"
		2:
			self.name="Redy"
		3:
			self.name="Greeny"

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
	if self.extra_moves.size()>0 and self.can_some_piece_move():
		return true
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
	
func some_piece_is_in_barrier():
	for p in self.pieces:
		if p.square().has_barrier():
			return true
	return false

func has_won():
	for p in self.pieces:
		if p.square().type!=Globals.eSquareTypes.END:
			return false
	return true

	

func can_some_piece_move_to_first_square():
	for p in self.pieces:
		if p.must_move_to_first_square():
			return true
	return false
	

func some_piece_is_in_barrier_of_my_player():
	for p in self.pieces:
		if p.am_i_in_a_barrier_of_my_player()==true:
			return true
	return false


func ia_selects_piece_to_move():
	for p in self.pieces:
		if p.can_move_to_route_position(p.route_position+p.squares_to_move()):
			return p
	print("IA COUDN?T FIND A PIECE TO MOVE")
