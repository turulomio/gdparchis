
#Para depurar @tyool reiniciar en consola godot --editor y se ven logs

extends Node3D
class_name Player

@onready var _Dice=$Dice
#@onready var _Piece0=$Piece0
#@onready var _Piece1=$Piece1
#@onready var _Piece2=$Piece2
#@onready var _Piece3=$Piece3
@export var id: int: 
	set(value):
		id=value
var show_pieces:bool

var color: Color
var _route: Route
var can_throw_dice: bool = false: set = set_can_throw_dice
var can_move_pieces: bool = false: set = set_can_move_pieces
var dice_throws=[]
var extra_moves=[]
var last_piece_moved=null
var plays=true
var ia=false

var playername#Name seems the name of the class

func _to_string():
	return "[Player: "+ str(self.id) + "]"

func initialize(_show_pieces):
	self.show_pieces=_show_pieces
	self.color=Globals.ePlayer2Color(self.id)
	self.playername=Globals.ePlayerDefaultName(self.id)
	self.dice().set_my_position(5)	
	for piece in self.pieces():
		piece.initialize(self.color)
		piece.visible=self.show_pieces		
	
func board():
	return self.get_parent_node_3d()
	
func game():
	var r=self.board().get_parent_node_3d()
	#print("Game of" , self, r)
	return r

func dice():
	return _Dice

func pieces():
	# No se puede utlizar el grupo porque en pieces añade todas las piezas del tree
	# REturns a list of players pieces
	var r= []
	for children in self.get_children():
		if children is Piece:
			r.append(children)
	return r
	
func route():
	return self._route

func set_route(p):
	self._route=p
	
func set_can_throw_dice(v):
	can_throw_dice=v
	if v==true:
		self.dice().TweenWaiting_start()
	else:
		self.dice().TweenWaiting_stop()
		
	## If a piece hits dice during game and falls, needs to be repositioned
	if self.dice().global_transform.origin.y<0:
		self.dice().get_node("FloatingText").show_text(tr("Recovering dice"),self.color)
		self.dice().set_my_position(5)


func set_can_move_pieces(b):
	can_move_pieces=b
	if b==true:
		for p in self.pieces():
			if self.ia==false and p.route_position!=p.route().end_position():
				p.TweenWaiting_start()
	else:
		for p in self.pieces():
			p.TweenWaiting_stop()
	
func last_throw():
	return self.dice_throws[self.dice_throws.size()-1]

## Returns if player is game current player
func is_current():
	if self == self.game().current_player:
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
	if self.dice().value==6 and self.dice_throws.size()<3:
		return true
	return false
	
func are_all_pieces_out_of_home():
	for p in self.pieces():
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
	for p in self.pieces():
		if p.can_move_stm():
			r.append(p)
	return r
	
func some_piece_is_in_barrier():
	for p in self.pieces():
		if p.square().has_barrier():
			return true
	return false

func can_some_piece_go_final_square_with_dice_movement():
	for p in self.pieces():
		if p.can_go_final_square_with_dice_movement():
			return true
	return false

func has_won():
	for p in self.pieces():
		if p.square().type!=Globals.eSquareTypes.END:
			return false
	return true

func can_some_piece_move_to_first_square():
	for p in self.pieces():
		if p.must_move_to_first_square():
			return true
	return false

func some_piece_is_in_barrier_of_my_player():
	for p in self.pieces():
		if p.am_i_in_a_barrier_of_my_player()==true:
			return true
	return false


func ia_selects_piece_to_move():
	randomize()
	
	## Pieces can move
	var pieces_can_move=[]
	for p in self.pieces():
		if p.can_move_stm():
			pieces_can_move.append(p)
			
	for p in pieces_can_move:
		#var attempt= rand_range(0,1)
		var attempt=1
		if p.can_eat_at_route_position(p.route_position+p.squares_to_move(),false) and attempt>Globals.difficulty_probability():
			print("Selected due to can eat")
			return p
	# Reduce risks
	for p in pieces_can_move:
		var square_final=p.player().route().square_at(p.route_position+p.squares_to_move()) #Could be null
		if square_final!=null and p.threats_at(p.square()).size()>p.threats_at(square_final).size():
			print("Selected due to less threats")
			return p
	
	
	#Find a movable piece
	for p in pieces_can_move:
		print("Selected due to can move")
		return p
	print("IA COUDN'T FIND A PIECE TO MOVE")



