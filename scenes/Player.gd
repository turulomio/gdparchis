class_name Player
var id : int
var name : String
var color: Color
var e_color
var pieces=[]
var route: Route
var dice: Dice
var game
var can_throw_dice = false setget set_can_throw_dice
var can_move_pieces = false setget set_can_move_pieces
var dice_throws=[]
var extra_moves=[]
var last_piece_moved=null
var plays=true
var ia=false


func _init(_id,_plays,_ia):
	self.id=_id
	self.e_color=_id
	self.color=Globals.colorn(self.e_color)
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
	
func set_can_throw_dice(v):
	can_throw_dice=v
	if v==true:
		self.dice.TweenWaiting_start()
	else:
		self.dice.TweenWaiting_stop()
		
	## If a piece hits dice during game and falls, needs to be repositioned
	if self.dice.global_transform.origin.y<0:
		self.dice.get_node("FloatingText").show_text(tr("Recovering dice"),self.color)
		self.dice.set_position(5)

func set_can_move_pieces(b):
	can_move_pieces=b
	if b==true:
		for p in self.pieces:
			if self.ia==false and p.route_position!=p.route.end_position():
				p.TweenWaiting_start()
	else:
		for p in self.pieces:
			p.TweenWaiting_stop()
	
func last_throw():
	return self.dice_throws[self.dice_throws.size()-1]

## Returns if player is game current player
func is_current():
	if self == self.game.players.current:
		return true
	return false
	
	
func dice_throws_has_three_sixes():
	if self.dice_throws.size()==3 and self.dice_throws[0]==6 and self.dice_throws[1]==6 and self.dice_throws[2]==6:
		return true
	return false
	
func can_move_other_piece_stm():
	if self.extra_moves.size()>0 and self.can_some_piece_move_stm():
		return true
	return false
	
func can_throw_dice_again():
	if self.dice.value==6 and self.dice_throws.size()<3:
		return true
	return false
	
func are_all_pieces_out_of_home():
	for p in self.pieces:
		if p.route_position==0:
			return false
	return true

func can_some_piece_move_stm():
	if pieces_can_move_stm().size()>0:
		return true
	return false

## Returns a list of pieces that this player can move
func pieces_can_move_stm():
	var r=[]
	for p in self.pieces:
		if p.can_move_stm():
			r.append(p)
	return r
	
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
	randomize()
	#Find if can eat
	for p in self.pieces:
		#var attempt= rand_range(0,1)
		var attempt=1
		if p.can_move_stm() and p.can_eat_at_route_position(p.route_position+p.squares_to_move(),false) and attempt>Globals.difficulty_probability():
			return p
			
	# Reduce risks
	for p in self.pieces:
		var square_final=p.route.square_at(p.route_position+p.squares_to_move()) #Could be null
		if square_final and p.threats_at(p.square())>p.threats_at(square_final):
			return p
	
	
	#Find a movable piece
	for p in self.pieces:
		if p.can_move_stm():
			return p
	print("IA COUDN'T FIND A PIECE TO MOVE")



