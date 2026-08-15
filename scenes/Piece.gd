extends RigidBody3D
class_name Piece

@export var id: int: 
	set(value):
		id = value

signal piece_moved

var vel : Vector3 = Vector3(0, -30, 0)
@onready var MeshInstance = $MeshInstance

var color: Color
var route_position: int 
var square_position: int
var TweenWaiting


## Initializes piece properties including material, color, varnish finish, and mass.
## @param color_ Player color assigned to this piece.
func initialize(color_):
	# Force piece mass to 24.0 kg (20x heavier than dice)
	self.mass = 24.0
	self.color = color_
	
	# Create StandardMaterial3D with wood texture and polished clearcoat
	var new_material = StandardMaterial3D.new()
	new_material.albedo_texture = Globals.IMAGE_WOOD
	new_material.albedo_color = self.color
	new_material.roughness = 0.3
	new_material.metallic_specular = 0.5
	new_material.clearcoat_enabled = true
	new_material.clearcoat = 0.4
	new_material.clearcoat_roughness = 0.15
	if MeshInstance != null:
		MeshInstance.material_override = new_material


## Sets piece target positions and updates global transform origin.
## Returns the 3D position coordinate for a given square ID and sub-position slot.
func get_3d_position(square_id: int, sq_pos: int, h: float = 0.2) -> Vector3:
	var b = self.board()
	if b and b.has_method("get_position3d"):
		return b.get_position3d(square_id, sq_pos, h)
	return Globals.position4(square_id, sq_pos, h)


## Sets piece target positions and updates global transform origin.
## @param _route_position Index in player route.
## @param _square_position Sub-index inside destination square.
## @param square_id Global board square identifier.
func set_final_position(_route_position, _square_position, square_id):
	self.route_position = _route_position
	self.square_position = _square_position
	self.global_transform.origin = self.get_3d_position(square_id, self.square_position, 0.2)
	self.rotation = Vector3.ZERO


## Performs a smooth corrective alignment animation, snapping the piece to its exact square slot and 3D upright stance on the board floor.
## @param duration Interpolation duration in seconds.
func correct_position_and_drop(duration = 0.15):
	if not self.square():
		return
		
	var target_3d = self.get_3d_position(self.square().id, self.square_position, 0.2)
	
	# Smoothly align position XZ, snap height Y=0.2, and reset 3D rotation upright
	var tween_correct = create_tween().set_parallel(true)
	tween_correct.tween_property(self, "global_transform:origin", target_3d, duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween_correct.tween_property(self, "rotation", Vector3.ZERO, duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	
	await tween_correct.finished
	self.set_physics_process(false)
	self.freeze = true


## Returns the parent Player node instance.
## @return Player node.
func player():
	return self.get_parent_node_3d()


## Returns the grand-parent Board node instance.
## @return Board node.
func board():
	return self.player().get_parent_node_3d()


## Returns the root Game node instance.
## @return Game node.
func game():
	return self.board().get_parent_node_3d()


## Returns the route object associated with the owner player.
## @return Route node.
func route():
	return self.player().route()


## Returns the unique global piece index across the entire board (0 to 15).
## @return Global piece index.
func total_id():
	return self.player().id * 4 + self.id


## String representation helper for debugging.
## @return Formatted string identifier.
func _to_string():
	return "[Piece: " + str(self.id) + "]"


## Returns the current Square object where the piece is standing.
## @return Square object.
func square():
	return self.route().square_at(self.route_position)


## Evaluates whether this piece can legally move to a given target route position.
## @param _route_position Target route position index.
## @return True if movement to target position is allowed.
func can_move_to_route_position(_route_position):
	var square_initial = self.square()
	var square_final = self.route().square_at(_route_position)
	
	# Priority rule: Must open exit square with a 5 if another piece can move there
	if self.route().square_at(1).has_barrier_of_this_player(self.player()) == false and self.must_move_to_first_square() == false and self.player().can_some_piece_move_to_first_square() == true:
		return false
	
	# Start home pieces can only exit with a roll of 5
	if square_initial.type == Globals.eSquareTypes.START and self.player().last_throw() != 5:
		return false

	# Cannot exceed maximum route length
	if square_final == null:		
		return false
		
	# Barrier break rule: If a 6 is rolled, player must break a barrier ONLY IF at least one piece in the barrier can legally move
	if self.player().last_throw() == 6 and self.am_i_in_a_barrier_of_my_player() == false:
		if self.player().some_piece_in_barrier_of_my_player_can_move() == true:
			return false
		
	# Check for intermediate barriers blocking the path
	if self.route().is_there_barrier(self.route_position, _route_position):
		return false
		
	# Verify available slot in target square
	var new_square_position = square_final.empty_position()
	if self.must_move_to_first_square() == false and new_square_position == -1:
		return false

	return true


## Animates smooth sequential step-by-step hops along intermediate route squares.
## @param _route_position Destination route index.
## @param duration Overall duration modifier.
## @param max_height Legacy peak arc height (used for single return jumps).
func move_to_route_position(_route_position, duration = 0.4, max_height = 4.0):
	# Calculate initial and final square assignments
	var square_final = self.route().square_at(_route_position)
	var square_initial = self.square()
	var square_position_initial = self.square_position
	var initial_route_pos = self.route_position

	# Update board square slots
	square_initial.set_piece_at_square_position(square_position_initial, null)
	var square_position_final = square_final.empty_position()
	square_final.set_piece_at_square_position(square_position_final, self)
	self.square_position = square_position_final
	self.route_position = _route_position	

	print("Moviendo ", self.player(), " ", self, " ", square_initial, " ", square_position_initial, " ", square_final, " ", square_position_final)
	
	self.player().can_move_pieces = false
	if duration > 0:
		# Calculate speed scale multiplier relative to default move duration (0.4s)
		var speed_mult: float = duration / 0.4
		var start_3d = self.get_3d_position(square_initial.id, square_position_initial)
		var final_3d = self.get_3d_position(square_final.id, square_position_final)
		
		# If returning home or single-step teleport
		if _route_position == 0 or initial_route_pos == _route_position or _route_position < initial_route_pos:
			var dest_scale = Vector3(0.75, 0.75, 0.75) if is_special_square_id(square_final.id) else Vector3(1, 1, 1)
			var mid_single = (start_3d + final_3d) / 2.0 + Vector3(0, max_height, 0)
			var half_single_dur = 0.25 * speed_mult
			var tween_single = get_tree().create_tween()
			tween_single.tween_property(self, "global_transform:origin", mid_single, half_single_dur).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
			tween_single.tween_property(self, "global_transform:origin", final_3d, half_single_dur).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
			tween_single.parallel().tween_property(self, "scale", dest_scale, half_single_dur * 2.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
			await tween_single.finished
		else:
			# Build list of 3D waypoint positions for each intermediate square step
			var waypoints: Array[Vector3] = []
			var total_steps = _route_position - initial_route_pos
			
			for step_idx in range(1, total_steps + 1):
				var step_rpos = initial_route_pos + step_idx
				var step_sq = self.route().square_at(step_rpos)
				if step_idx == total_steps:
					waypoints.append(final_3d)
				else:
					waypoints.append(self.get_3d_position(step_sq.id, 0))
			
			# Execute smooth sequential hops from square to square
			var current_pos = start_3d
			var hop_duration = 0.13 * speed_mult
			# Cruising altitude set to piece height * 1.10 (1.10 units above ground floor)
			var cruise_y: float = 1.10
			var apex_add_y: float = 0.8
			
			for step_idx in range(waypoints.size()):
				var is_last_step = (step_idx == waypoints.size() - 1)
				var next_waypoint = waypoints[step_idx]
				
				# Intermediate waypoints maintain cruising height (3.0) above standing pieces
				var dest_pos = next_waypoint if is_last_step else Vector3(next_waypoint.x, cruise_y, next_waypoint.z)
				var step_sq = self.route().square_at(initial_route_pos + step_idx + 1)
				
				# Target 0.75 scale if stepping onto special corridor square, otherwise restore normal 1.0 scale
				var target_scale = Vector3(0.75, 0.75, 0.75) if (step_sq != null and is_special_square_id(step_sq.id)) else Vector3(1, 1, 1)
				var mid_y = max(current_pos.y, dest_pos.y) + apex_add_y
				var mid_pos = Vector3((current_pos.x + dest_pos.x) / 2.0, mid_y, (current_pos.z + dest_pos.z) / 2.0)
				
				var tween_hop = get_tree().create_tween()
				# Sequential origin parabolic arc (upward half, then downward half)
				tween_hop.tween_property(self, "global_transform:origin", mid_pos, hop_duration / 2.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
				tween_hop.tween_property(self, "global_transform:origin", dest_pos, hop_duration / 2.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
				# Parallel scale interpolation across the entire hop duration
				tween_hop.parallel().tween_property(self, "scale", target_scale, hop_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
				await tween_hop.finished
				
				current_pos = dest_pos
				
			# Soft touchdown bounce on final destination square matching target square scale
			var bounce_tween = get_tree().create_tween()
			var dest_scale = Vector3(0.75, 0.75, 0.75) if is_special_square_id(square_final.id) else Vector3(1, 1, 1)
			bounce_tween.tween_property(self, "scale", Vector3(dest_scale.x * 1.08, dest_scale.y * 0.88, dest_scale.z * 1.08), 0.05 * speed_mult)
			bounce_tween.tween_property(self, "scale", dest_scale, 0.07 * speed_mult)
			await bounce_tween.finished
		
		# Smoothly correct any displacement and drop cleanly onto board floor (h=0.2)
		await self.correct_position_and_drop(0.12 * speed_mult)
		
	# Adjust visual scale on narrow corridor squares and signal completion
	self.change_scale_on_specials_squares()
	emit_signal("piece_moved")


## Helper evaluating whether a given square ID is a special narrow corridor square.
## @param sq_id Square ID integer.
## @return True if square requires reduced scale.
func is_special_square_id(sq_id: int) -> bool:
	if self.board() != null and self.board().max_players == 4:
		return sq_id in [8, 9, 25, 26, 42, 43, 59, 60]
	return false


## Adjusts visual piece scale when placed on special narrow corridor squares.
## @param sq_id Target square ID integer (defaults to current standing square).
func change_scale_on_specials_squares(sq_id: int = -1):
	if sq_id == -1:
		if self.square():
			sq_id = self.square().id
		else:
			sq_id = 0
			
	if is_special_square_id(sq_id):
		self.scale = Vector3(0.75, 0.75, 0.75)
	else:
		self.scale = Vector3(1, 1, 1)


## Returns the number of squares this piece should move based on throw and extra moves.
## @return Number of squares to advance.
func squares_to_move():
	if self.player().extra_moves.size() > 0:
		return self.player().extra_moves[0]
	
	var lt = self.player().last_throw()
	if lt == 0 or lt == null:
		return 0
		
	if self.square() != null and self.square().type == Globals.eSquareTypes.START and lt == 5:
		return 1
	elif self.player().are_all_pieces_out_of_home() and lt == 6:
		return 7
	else:
		return lt


## Checks if this piece is forming a barrier with another piece of the same player.
## @return True if forming a barrier.
func am_i_in_a_barrier_of_my_player():
	var s = self.square()
	if s.has_barrier() == true:
		if s.pieces[0].player() == self.player() and s.pieces[1].player() == self.player():
			return true
	return false


## Returns an opponent piece that must be eaten prior to making the move (e.g. exit on 5 into occupied square).
## @return Piece object to capture or null.
func piece_to_eat_before_move():
	var square_initial = self.square()
	var stm = self.squares_to_move()
	if stm <= 0:
		return null
	var square_final = self.route().square_at(self.route_position + stm)
	if square_final == null:
		return null

	if square_final.pieces_count() == 2 and self.player().dice().value == 5 and square_initial.type == Globals.eSquareTypes.START:
		var ordered = square_final.pieces_different_to_me_ordered(self.player())
		if ordered != null:
			return ordered[0]
	return null


## Input handler for piece click selection. Executes movement, capture rules, and win conditions.
func on_clicked():
	var has_eaten_before = false	
	var has_eaten_after = false
	
	if self.can_move_stm() == true:
		# Process pre-move capture rule
		if self.can_eat_before_stm() == true:
			var eaten_before = self.piece_to_eat_before_move()
			has_eaten_before = true
			$Eat.play()
			$FloatingText.show_text(tr("{0}, I did it unintentionally! +20 moves").format([eaten_before.player().playername]), self.player().color)
			eaten_before.move_to_route_position(0)
			await eaten_before.piece_moved
		
		# Perform primary route movement
		self.move_to_route_position(self.route_position + self.squares_to_move())
		await self.piece_moved
		
		# Remove extra move tokens if consumed
		if self.squares_to_move() in [10, 20]:
			self.player().extra_moves.pop_front()
			
		# Process post-move capture rule
		if has_eaten_before == false and self.can_eat_at_route_position(self.route_position, true) == true:
			has_eaten_after = true
			$Eat.play()			
			var piece_eaten = self.square().pieces_different_to_me_ordered(self.player())[0]
			$FloatingText.show_text(tr("{0}, you're so tasty! +20 moves").format([piece_eaten.player().playername]), self.player().color)
			piece_eaten.move_to_route_position(0)
			await piece_eaten.piece_moved

		# Award +20 extra moves for capturing
		if has_eaten_before == true or has_eaten_after == true:
			self.player().extra_moves.append(20)
		
		# Check victory condition
		if self.player().has_won():
			$Won.play()
			if self.game() != null and "game_start_time" in self.game():
				Globals.add_game_history_entry(self.game().game_start_time, self.player(), self.board())
			$FloatingText.show_text(tr("Player {0} wins").format([self.player().playername]), self.player().color)
			await $FloatingText.text_disappear
			
			get_tree().change_scene_to_file.call_deferred("res://scenes/Main.tscn")
			return
			
		# Award +10 extra moves and display floating text for reaching the final goal square
		if self.square().type == Globals.eSquareTypes.END:
			$EndRoute.play()
			$FloatingText.show_text(tr("Piece in goal! +10 moves"), self.player().color)
			self.player().extra_moves.append(10)
			
		self.player().last_piece_moved = self
	else:
		$Click.play()
		return
	
	# Determine turn continuation or next player transition
	if self.player().can_move_other_piece_stm() == true:
		self.player().can_move_pieces = true
		if self.player().ia == true:
			self.player().ia_selects_piece_to_move().on_clicked()
		else:
			var pieces_can_move_stm = self.player().pieces_can_move_stm()
			print(self.player().playername, " PIECES CAN MOVE ", pieces_can_move_stm)
			if pieces_can_move_stm.size() == 1:
				pieces_can_move_stm[0].on_clicked()
		
	elif self.player().can_throw_dice_again():
		self.player().can_throw_dice = true
		if self.player().ia == true:
			self.player().dice().on_clicked()
		else:
			if Globals.settings.get("automatic", true) == true:
				self.player().dice().on_clicked()
	else:
		self.game().change_current_player()


## Evaluates if this piece is obligated to move out to the first home exit square.
## @return True if mandatory move to first square applies.
func must_move_to_first_square():
	if self.route_position != 0:
		return false
	var square_first = self.route().square_at(1)
	if self.player().extra_moves.size() == 0 and self.player().dice().value == 5 and self.player().are_all_pieces_out_of_home() == false:
		if square_first.pieces_count() < 2:
			return true
		else:
			var ordered = square_first.pieces_different_to_me_ordered(self.player())
			if ordered == null:
				return false
			else:
				return true
	return false


var base_y_position: float = 0.2


## Helper function for smooth floating hover oscillation.
## @param val Normalized height offset.
func TweenWaiting_method(val):
	self.global_transform.origin.y = self.base_y_position + val


## Starts smooth hover animation indicating the piece is available for player selection.
func TweenWaiting_start():
	if self.visible == false:
		return
		
	self.set_physics_process(false)	
	self.freeze = true
	
	if self.square():
		var ground_pos = Globals.position4(self.square().id, self.square_position, 0.2)
		self.base_y_position = ground_pos.y
	else:
		self.base_y_position = 0.2

	if TweenWaiting:
		TweenWaiting.kill()
		
	# Smoothly bob up and down between +0.35 and +1.35 above ground level (amplitude = 1.0) with TRANS_SINE
	TweenWaiting = create_tween().set_loops()
	TweenWaiting.tween_method(TweenWaiting_method, 0.35, 1.35, 0.8).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	TweenWaiting.tween_method(TweenWaiting_method, 1.35, 0.35, 0.8).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


## Stops hover selection animation and smoothly lowers piece back to board floor.
func TweenWaiting_stop():
	if self.visible == false:
		return
	if TweenWaiting:
		TweenWaiting.kill()
		TweenWaiting = null
		
	# Smoothly correct position and descend back to ground floor level (0.2)
	await self.correct_position_and_drop(0.12)


## Evaluates whether this piece can move given current state machine status.
## @return True if piece can make a valid move.
func can_move_stm():
	return self.can_move_to_route_position(self.route_position + self.squares_to_move())


## Evaluates whether moving to a route position results in capturing an opponent piece.
## @param _route_position Target route index.
## @param check_after_movement If true, evaluates state post-movement.
## @return True if capture condition is met.
func can_eat_at_route_position(_route_position, check_after_movement):
	# 1. Fetch square object at target route position and return false if position is out of bounds
	var square_ = self.route().square_at(_route_position)
	if square_ == null:
		return false

	# 2. Evaluate pre-movement vs post-movement capture conditions on NORMAL type squares
	if check_after_movement == false and self.can_move_to_route_position(_route_position):
		if square_.pieces_count() == 1 and square_.type == Globals.eSquareTypes.NORMAL and square_.pieces_objects()[0].player() != self.player():
			return true
	else:
		if square_.pieces_count() == 2 and square_.type == Globals.eSquareTypes.NORMAL and square_.pieces_different_to_me_ordered(self.player()) != null:
			return true
	return false


## Evaluates whether a pre-movement capture must occur.
## @return True if pre-movement capture applies.
func can_eat_before_stm():
	return piece_to_eat_before_move() != null


## Checks if piece can reach the final goal square with any dice roll.
## @return True if goal square is within reach.
func can_go_final_square_with_dice_movement():
	if self.route_position + 1 == self.route().end_position():
		return true
	if self.route_position + 2 == self.route().end_position():
		return true
	if self.route_position + 3 == self.route().end_position():
		return true
	if self.route_position + 4 == self.route().end_position():
		return true
	if self.player().are_all_pieces_out_of_home():
		if self.route_position + 5 == self.route().end_position():
			return true
		if self.route_position + 7 == self.route().end_position():
			return true
	else:
		if self.route_position + 6 == self.route().end_position():
			return true
	return false


## Evaluates whether an opponent stalker piece poses a threat to capture this piece at a specific target square.
## Step 1: Ignore self or non-route squares.
## Step 2: Calculate step distance along the stalker's route to the target square.
## Step 3: Check for intermediate barriers blocking the stalker's path.
## Step 4: Exclude safe squares (START, RAMP, SECURE, END) or friendly barriers.
## Step 5: Check single die roll threats (1, 2, 3, 4, 6/7, 5 when all pieces out).
## Step 6: Check +20 eat bonus threats (active +20 extra move or potential capture move).
## Step 7: Check +10 goal bonus threats (active +10 extra move or potential goal entry move).
## Step 8: Check FIRST exit square capture threats on rolling a 5.
## @param stalker Opponent piece object being evaluated.
## @param _square Target square to evaluate for threats.
## @return True if stalker can capture this piece at target square.
func is_threating_me(stalker, _square):
	var stalker_square = stalker.square()
	if stalker_square == _square:
		return false
		
	# 1. Pieces inside home base (START square) can only threaten their own FIRST exit square on rolling 5
	if stalker_square.type == Globals.eSquareTypes.START:
		if not (_square.type == Globals.eSquareTypes.FIRST and _square.color == stalker.player().color):
			return false
			
	# 2. Verify target square exists in stalker's route
	var stalker_pos_target = stalker.route().position_in_route(_square)
	if stalker_pos_target == -1:
		return false
		
	# 3. Calculate step distance along stalker's route to target square
	var distance = stalker.route().distance_between_squares(stalker_square, _square)
	if distance == null or distance <= 0:
		return false
		
	# 4. Check if intermediate barriers block stalker from reaching target square
	var stalker_pos_initial = stalker.route().position_in_route(stalker_square)
	if stalker.route().is_there_barrier(stalker_pos_initial, stalker_pos_target):
		return false
	
	# 5. Exclude safe square types where captures cannot occur
	if _square.type in [Globals.eSquareTypes.START, Globals.eSquareTypes.RAMP, Globals.eSquareTypes.SECURE, Globals.eSquareTypes.END]:
		return false

	# 6. Exclude target squares containing a friendly barrier of this piece's player
	if _square.has_barrier_of_this_player(self.player()):
		return false
		
	var stalker_pieces_all_out = stalker.player().are_all_pieces_out_of_home()
	var mysix = 7 if stalker_pieces_all_out else 6

	# 7. Standard die roll threats (1, 2, 3, 4, or 6/7) on NORMAL squares
	if _square.type in [Globals.eSquareTypes.NORMAL] and distance in [1, 2, 3, 4, mysix]:
		return true

	# 8. Die roll 5 threat on NORMAL squares when all stalker's pieces are out of home
	if stalker_pieces_all_out == true and _square.type in [Globals.eSquareTypes.NORMAL] and distance == 5:
		return true

	# 9. Threat at 20 squares (eat bonus): either stalker has an active +20 in extra_moves or can eat an opponent piece on this turn
	if _square.type in [Globals.eSquareTypes.NORMAL] and distance == 20:
		if 20 in stalker.player().extra_moves or stalker.player().can_some_piece_eat_stm():
			return true

	# 10. Threat at 10 squares (goal bonus): either stalker has an active +10 in extra_moves or can enter goal on this turn
	if _square.type in [Globals.eSquareTypes.NORMAL] and distance == 10:
		if 10 in stalker.player().extra_moves or stalker.player().can_some_piece_go_final_square_with_dice_movement():
			return true

	# 11. Exit home threat on FIRST square when stalker rolls a 5 and exit square is occupied
	if _square.type == Globals.eSquareTypes.FIRST and stalker.player().color == _square.color and _square.pieces_count() == 2 and _square.has_barrier_of_this_player(self.player()) == false:
		return true

	return false


## Returns a list of opponent pieces currently threatening to capture this piece at a given square.
## @param square Target square to check.
## @return Array of threatening opponent Piece objects.
func threats_at(square):
	if square == null:
		return []
	var r = []
	for player_ in self.player().board().players():
		if player_ == self.player():
			continue
		for stalker in player_.pieces():
			if self.is_threating_me(stalker, square):
				r.append(stalker)
	return r
