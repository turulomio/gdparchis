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
	if _Dice == null:
		_Dice = get_node_or_null("Dice")
	if _Dice == null:
		var dice_script = load("res://scenes/Dice.gd")
		_Dice = dice_script.new()
		add_child(_Dice)
	return _Dice


## Returns an array of child Piece instances.
## @return Array of Piece objects.
func pieces() -> Array[Piece]:
	var r: Array[Piece] = []
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
			# Only pieces of human players that can make a valid move in this turn oscillate
			if self.ia == false and p.can_move_stm() == true:
				p.TweenWaiting_start()
			else:
				p.TweenWaiting_stop()
	else:
		for p in self.pieces():
			p.TweenWaiting_stop()


## Returns the value of the last dice throw.
## @return Integer value.
func last_throw() -> int:
	if self.dice_throws.size() == 0:
		return 0
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


## Checks if any piece of this player can capture an opponent piece on this turn.
## @return True if a capture move is available.
func can_some_piece_eat_stm() -> bool:
	for p in self.pieces():
		var stm = p.squares_to_move()
		if stm > 0:
			if p.can_eat_before_stm() or p.can_eat_at_route_position(p.route_position + stm, false):
				return true
	return false


## Checks if any piece forming a barrier belonging to this player can legally move.
## @return True if at least one piece in a barrier of this player has a valid legal move.
func some_piece_in_barrier_of_my_player_can_move() -> bool:
	for p in self.pieces():
		if p.am_i_in_a_barrier_of_my_player() == true:
			var target_pos = p.route_position + p.squares_to_move()
			var sq_final = p.route().square_at(target_pos)
			if sq_final != null:
				if not p.route().is_there_barrier(p.route_position, target_pos):
					if sq_final.empty_position() != -1:
						return true
	return false


## AI decision logic selecting the best piece to move based on capture priority, threat reduction, and advance progress.
## Step 1: Collect all pieces capable of making a valid legal move on this turn.
## Step 2: Priority 1 - Evaluate capture moves (eat opponent). Triggered when randf() <= difficulty_probability (Easy: 55%, Normal: 75%, Hard: 95%).
## Step 3: Priority 2 - Evaluate threat reduction moves (escape danger or move into safe square). Triggered when randf() <= difficulty_probability.
## Step 4: Priority 3 - Prefer advancing pieces currently standing outside safe squares (NORMAL type).
## Step 5: Priority 4 - Select the piece furthest advanced along its route towards goal (highest route_position).
## @return Selected Piece object to move, or null if no legal moves exist.
func ia_selects_piece_to_move():
	randomize()
	
	# Step 1: Collect all pieces capable of making a valid move
	var pieces_can_move = []
	for p in self.pieces():
		if p.can_move_stm():
			pieces_can_move.append(p)
			
	if pieces_can_move.is_empty():
		print("IA COULDN'T FIND A PIECE TO MOVE")
		return null
			
	# Step 2: Priority 1 - Select piece that can capture an opponent piece
	for p in pieces_can_move:
		var attempt = randf()
		if p.can_eat_at_route_position(p.route_position + p.squares_to_move(), false) and attempt <= Globals.difficulty_probability():
			print("Selected due to can eat")
			return p
			
	# Step 3: Priority 2 - Select piece that moves away from threats or into safety
	for p in pieces_can_move:
		var square_final = p.player().route().square_at(p.route_position + p.squares_to_move())
		var attempt = randf()
		if square_final != null and p.threats_at(p.square()).size() > p.threats_at(square_final).size() and attempt <= Globals.difficulty_probability():
			print("Selected due to less threats")
			return p
	
	# Step 4: Priority 3 - Prefer moving a piece that is outside a safe square (NORMAL type square)
	var pieces_outside_secure = []
	for p in pieces_can_move:
		if p.square() and p.square().type == Globals.eSquareTypes.NORMAL:
			pieces_outside_secure.append(p)
			
	var candidate_pool = pieces_outside_secure if not pieces_outside_secure.is_empty() else pieces_can_move
	
	# Step 5: Priority 4 - Select the most advanced piece in candidate pool (highest route_position towards goal)
	var best_piece = candidate_pool[0]
	for p in candidate_pool:
		if p.route_position > best_piece.route_position:
			best_piece = p
			
	print("Selected most advanced piece (outside secure preference)")
	return best_piece
