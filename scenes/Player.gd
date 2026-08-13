extends Node3D
class_name Player

@onready var _Dice = $Dice
@export var id: int: 
	set(value):
		id = value
var show_pieces: bool

var color: Color
var _route: Route
var can_throw_dice: bool = false: set = set_can_throw_dice
var can_move_pieces: bool = false: set = set_can_move_pieces
var dice_throws = []
var extra_moves = []
var last_piece_moved = null
var plays = true
var ia = false
var playername


## Returns string representation for debugging.
## @return String identifier.
func _to_string():
	return "[Player: " + str(self.id) + "]"


## Initializes player properties, color, default name, dice position, and child pieces.
## @param _show_pieces Boolean indicating if pieces are visible.
func initialize(_show_pieces):
	self.show_pieces = _show_pieces
	self.color = Globals.ePlayer2Color(self.id)
	self.playername = Globals.ePlayerDefaultName(self.id)
	self.dice().set_my_position(5)	
	self.dice().apply_soft_tint(self.color)
	self.dice().visible = self.is_current()
	for piece in self.pieces():
		piece.initialize(self.color)
		piece.visible = self.show_pieces		


## Returns parent Board node instance.
## @return Board node.
func board():
	return self.get_parent_node_3d()


## Returns root Game node instance.
## @return Game node.
func game():
	return self.board().get_parent_node_3d()


## Returns Dice child node instance.
## @return Dice node.
func dice():
	return _Dice


## Returns an array of child Piece instances.
## @return Array of Piece objects.
func pieces():
	var r = []
	for children in self.get_children():
		if children is Piece:
			r.append(children)
	return r


## Returns Route object assigned to this player.
## @return Route object.
func route():
	return self._route


## Assigns a Route object to this player.
## @param p Route object.
func set_route(p):
	self._route = p


## Setter for can_throw_dice property. Toggles dice hover animation.
## @param v Boolean flag.
func set_can_throw_dice(v):
	can_throw_dice = v
	if v == true:
		self.dice().TweenWaiting_start()
	else:
		self.dice().TweenWaiting_stop()
		
	# Reposition dice if it fell out of bounds
	if self.dice().global_transform.origin.y < 0:
		self.dice().get_node("FloatingText").show_text(tr("Recovering dice"), self.color)
		self.dice().set_my_position(5)


## Setter for can_move_pieces property. Toggles piece hover animation for selectable pieces.
## @param b Boolean flag.
func set_can_move_pieces(b):
	can_move_pieces = b
	if b == true:
		for p in self.pieces():
			if self.ia == false and p.route_position != p.route().end_position():
				p.TweenWaiting_start()
	else:
		for p in self.pieces():
			p.TweenWaiting_stop()


## Returns the value of the last dice throw.
## @return Integer value.
func last_throw():
	return self.dice_throws[self.dice_throws.size() - 1]


## Checks if this player is the active current player in the game.
## @return True if active player.
func is_current():
	var g = self.game()
	if g != null and "current_player" in g:
		return self == g.current_player
	return false


## Checks if the player rolled three consecutive 6s.
## @return True if three 6s in a row.
func dice_throws_has_three_sixes():
	if self.dice_throws.size() == 3 and self.dice_throws[0] == 6 and self.dice_throws[1] == 6 and self.dice_throws[2] == 6:
		return true
	return false


## Evaluates if player has pending extra moves and can move a piece.
## @return True if player can move another piece with extra moves.
func can_move_other_piece_stm():
	if self.extra_moves.size() > 0 and self.can_some_piece_move_stm():
		return true
	return false


## Evaluates if player is allowed to throw dice again (rolled a 6 and under 3 throws).
## @return True if roll again is permitted.
func can_throw_dice_again():
	if self.dice().value == 6 and self.dice_throws.size() < 3:
		return true
	return false


## Checks if all 4 pieces of this player have left the start home area.
## @return True if all pieces are on the board.
func are_all_pieces_out_of_home():
	for p in self.pieces():
		if p.route_position == 0:
			return false
	return true


## Evaluates if at least one piece of this player has a legal move available.
## @return True if any piece can move.
func can_some_piece_move_stm():
	return pieces_can_move_stm().size() > 0


## Returns an array of Piece objects belonging to this player that can make a valid move.
## @return Array of movable Piece objects.
func pieces_can_move_stm():
	var r = []
	for p in self.pieces():
		if p.can_move_stm():
			r.append(p)
	return r


## Checks if any piece of this player is currently forming part of a barrier.
## @return True if a barrier exists.
func some_piece_is_in_barrier():
	for p in self.pieces():
		if p.square().has_barrier():
			return true
	return false


## Checks if any piece can reach the final goal square.
## @return True if goal square is reachable.
func can_some_piece_go_final_square_with_dice_movement():
	for p in self.pieces():
		if p.can_go_final_square_with_dice_movement():
			return true
	return false


## Checks if all 4 pieces have reached the final goal square.
## @return True if player has won.
func has_won():
	for p in self.pieces():
		if p.square().type != Globals.eSquareTypes.END:
			return false
	return true


## Checks if any piece is mandated to move out to the first home exit square.
## @return True if compulsory exit move applies.
func can_some_piece_move_to_first_square():
	for p in self.pieces():
		if p.must_move_to_first_square():
			return true
	return false


## Checks if any piece is currently forming a barrier belonging exclusively to this player.
## @return True if player owns a barrier.
func some_piece_is_in_barrier_of_my_player():
	for p in self.pieces():
		if p.am_i_in_a_barrier_of_my_player() == true:
			return true
	return false


## AI decision logic selecting the best piece to move based on capture priority and threat reduction.
## @return Selected Piece object to move.
func ia_selects_piece_to_move():
	randomize()
	
	# Find all pieces capable of making a valid move
	var pieces_can_move = []
	for p in self.pieces():
		if p.can_move_stm():
			pieces_can_move.append(p)
			
	# Priority 1: Select piece that can capture an opponent piece
	for p in pieces_can_move:
		var attempt = 1
		if p.can_eat_at_route_position(p.route_position + p.squares_to_move(), false) and attempt > Globals.difficulty_probability():
			print("Selected due to can eat")
			return p
			
	# Priority 2: Select piece that moves away from threats or into safety
	for p in pieces_can_move:
		var square_final = p.player().route().square_at(p.route_position + p.squares_to_move())
		if square_final != null and p.threats_at(p.square()).size() > p.threats_at(square_final).size():
			print("Selected due to less threats")
			return p
	
	# Priority 3: Fallback to first available movable piece
	for p in pieces_can_move:
		print("Selected due to can move")
		return p
		
	print("IA COULDN'T FIND A PIECE TO MOVE")
	return null
