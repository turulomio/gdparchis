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
	MeshInstance.material_override = new_material


## Sets piece target positions and updates global transform origin.
## @param _route_position Index in player route.
## @param _square_position Sub-index inside destination square.
## @param square_id Global board square identifier.
func set_final_position(_route_position, _square_position, square_id):
	self.route_position = _route_position
	self.square_position = _square_position
	self.global_transform.origin = Globals.position4(square_id, self.square_position, 0.2)
	self.rotation = Vector3.ZERO


## Performs a smooth corrective alignment animation, snapping the piece to its exact square slot and 3D upright stance on the board floor.
## @param duration Interpolation duration in seconds.
func correct_position_and_drop(duration = 0.15):
	if not self.square():
		return
		
	var target_3d = Globals.position4(self.square().id, self.square_position, 0.2)
	
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
		
	# Barrier break rule: If a 6 is rolled and a barrier exists, player must break barrier
	if self.player().last_throw() == 6 and self.player().some_piece_is_in_barrier_of_my_player() == true and self.am_i_in_a_barrier_of_my_player() == false:
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
		var start_3d = Globals.position4(square_initial.id, square_position_initial)
		var final_3d = Globals.position4(square_final.id, square_position_final)
		
		# If returning home or single-step teleport
		if _route_position == 0 or initial_route_pos == _route_position or _route_position < initial_route_pos:
			var tween_single = get_tree().create_tween()
			var mid_single = (start_3d + final_3d) / 2.0 + Vector3(0, max_height, 0)
			var half_single_dur = 0.25 * speed_mult
			tween_single.tween_property(self, "global_transform:origin", mid_single, half_single_dur).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
			tween_single.tween_property(self, "global_transform:origin", final_3d, half_single_dur).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
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
					waypoints.append(Globals.position4(step_sq.id, 0))
			
			# Execute smooth sequential hops from square to square
			var current_pos = start_3d
			var hop_duration = 0.13 * speed_mult
			
			for step_idx in range(waypoints.size()):
				var next_pos = waypoints[step_idx]
				var mid_pos = (current_pos + next_pos) / 2.0 + Vector3(0, 1.8, 0)
				
				var tween_hop = get_tree().create_tween()
				tween_hop.tween_property(self, "global_transform:origin", mid_pos, hop_duration / 2.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
				tween_hop.tween_property(self, "global_transform:origin", next_pos, hop_duration / 2.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
				await tween_hop.finished
				
				current_pos = next_pos
				
			# Soft touchdown bounce on final destination square
			var bounce_tween = get_tree().create_tween()
			var cur_scale = self.scale
			bounce_tween.tween_property(self, "scale", Vector3(cur_scale.x * 1.08, cur_scale.y * 0.88, cur_scale.z * 1.08), 0.05 * speed_mult)
			bounce_tween.tween_property(self, "scale", cur_scale, 0.07 * speed_mult)
			await bounce_tween.finished
		
		# Smoothly correct any displacement and drop cleanly onto board floor (h=0.2)
		await self.correct_position_and_drop(0.12 * speed_mult)
		
	# Adjust visual scale on narrow corridor squares and signal completion
	self.change_scale_on_specials_squares()
	emit_signal("piece_moved")


## Adjusts visual piece scale when placed on special narrow corridor squares.
func change_scale_on_specials_squares():
	if self.board().max_players == 4:
		if self.square().id in [8, 9, 25, 26, 42, 43, 59, 60]:
			self.scale = Vector3(0.75, 0.75, 0.75)
		else:
			self.scale = Vector3(1, 1, 1)


## Returns the number of squares this piece should move based on throw and extra moves.
## @return Number of squares to advance.
func squares_to_move():
	if self.player().extra_moves.size() > 0:
		return self.player().extra_moves[0]
	
	if self.square().type == Globals.eSquareTypes.START and self.player().last_throw() == 5:
		return 1
	elif self.player().are_all_pieces_out_of_home() and self.player().last_throw() == 6:
		return 7
	else:
		return self.player().last_throw()


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
	var square_final = self.route().square_at(self.route_position + self.squares_to_move())

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
			$FloatingText.show_text(tr("Player {0} wins").format([self.player().name]), self.player().color)
			await $FloatingText.text_disappear
	
			print("Registering end of game:")	
			var fields = {
				"game_uuid": Globals.game_data.game_uuid,
				"human_won": not self.player().ia,
			}
			print(fields)
			Globals.request_put($RequestGameEnd, Globals.APIROOT + "/games/", fields)
			await $RequestGameEnd.request_completed
			
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
			print(self.player().name, " PIECES CAN MOVE ", pieces_can_move_stm)
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
			var ordered = square_first.pieces_different_to_me_ordered(self)
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
		
	# Smoothly bob up and down between +0.4 and +0.75 above ground level with TRANS_SINE
	TweenWaiting = create_tween().set_loops()
	TweenWaiting.tween_method(TweenWaiting_method, 0.4, 0.75, 0.8).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	TweenWaiting.tween_method(TweenWaiting_method, 0.75, 0.4, 0.8).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


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
	var square_ = self.route().square_at(_route_position)
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


## Evaluates whether an opponent stalker piece poses a threat to capture this piece at a specific square.
## @param stalker Opponent piece object.
## @param _square Target square to evaluate.
## @return True if stalker can capture this piece at target square.
func is_threating_me(stalker, _square):
	var stalker_square = stalker.square()
	if stalker_square == _square:
		return false
	if stalker.route().position_in_route(_square) == -1:
		return false
		
	var distance = self.route().distance_between_squares(stalker_square, _square)
	if distance == null:
		return false
	
	if _square.type in [Globals.eSquareTypes.START, Globals.eSquareTypes.RAMP, Globals.eSquareTypes.SECURE, Globals.eSquareTypes.END]:
		return false

	if _square.has_barrier_of_this_player(self.player()):
		return false
		
	var stalker_pieces_all_out = stalker.player().are_all_pieces_out_of_home()
	var mysix = 7 if stalker_pieces_all_out else 6

	if _square.type in [Globals.eSquareTypes.NORMAL] and distance in [1, 2, 3, 4, 20, mysix]:
		return true

	if stalker_pieces_all_out == true and _square.type in [Globals.eSquareTypes.NORMAL] and distance == 5:
		return true

	if stalker.player().can_some_piece_go_final_square_with_dice_movement():
		if _square.type in [Globals.eSquareTypes.NORMAL] and distance == 10:
			return true

	if _square.type == Globals.eSquareTypes.FIRST and stalker.player().color == _square.color and _square.pieces_count() == 2 and _square.has_barrier_of_this_player(self.player()) == false:
		return true

	return false


## Returns a list of opponent pieces currently threatening to capture this piece at a given square.
## @param square Target square to check.
## @return Array of threatening opponent Piece objects.
func threats_at(square):
	var r = []
	for player_ in self.player().board().players():
		if player_ == self.player():
			continue
		for stalker in player_.pieces():
			if self.is_threating_me(stalker, square):
				r.append(stalker)
	return r


## Completion handler for end of game HTTP request.
func _on_RequestGameEnd_request_completed(result, response_code, headers, body):
	if result == 0:
		var r = JSON.parse_string(body.get_string_from_utf8())
		print("  - ", r["success"], ": ", r["detail"])
	else:
		print("  -  Couldn't connect")
