class_name Dice
extends RigidBody3D

signal dice_got_value

var vel : Vector3 = Vector3(0, -30, 0)
var value = 0 # 0: uninitialized, null: rolling in progress, 1-6: face result determined
var has_touch = false
var collision_count: int = 0
var historical = [] # List storing all past rolls for statistics reporting
var tween_waiting
var stopped_frames: int = 0


## Returns the parent Player node associated with this dice.
## @return Player node instance.
func player():
	return self.get_parent_node_3d()


## Sets the initial spawn coordinates of the dice according to the player ID.
## @param h Height (Y coordinate) where the dice will be spawned.
func set_my_position(h):
	if not self.player():
		return
	var max_p = self.player().board().max_players if (self.player().board() != null) else 4
	if max_p == 6:
		match(self.player().id):
			0: self.global_transform.origin = Vector3(0, h, -28)
			1: self.global_transform.origin = Vector3(-25, h, -15)
			2: self.global_transform.origin = Vector3(-25, h, 15)
			3: self.global_transform.origin = Vector3(0, h, 28)
			4: self.global_transform.origin = Vector3(25, h, 15)
			5: self.global_transform.origin = Vector3(25, h, -15)
	elif max_p == 8:
		match(self.player().id):
			0: self.global_transform.origin = Vector3(8.0, h, 34.0)
			1: self.global_transform.origin = Vector3(-21.0, h, 28.0)
			2: self.global_transform.origin = Vector3(-35.0, h, 6.0)
			3: self.global_transform.origin = Vector3(-29.0, h, -19.0)
			4: self.global_transform.origin = Vector3(-8.0, h, -34.0)
			5: self.global_transform.origin = Vector3(17.0, h, -30.0)
			6: self.global_transform.origin = Vector3(34.0, h, -9.0)
			7: self.global_transform.origin = Vector3(30.0, h, 19.0)
	else:
		match(self.player().id):
			0: self.global_transform.origin = Vector3(-20, h, -25)
			1: self.global_transform.origin = Vector3(-25, h, 20)
			2: self.global_transform.origin = Vector3(20, h, 25)
			3: self.global_transform.origin = Vector3(25, h, -20)


## Helper method recursively collecting all MeshInstance3D nodes under a parent.
## @param node Root node to inspect.
## @return Array of MeshInstance3D instances found.
func _find_all_mesh_instances(node: Node) -> Array[MeshInstance3D]:
	var result: Array[MeshInstance3D] = []
	if node is MeshInstance3D:
		result.append(node)
	for child in node.get_children():
		result.append_array(_find_all_mesh_instances(child))
	return result


## Applies a soft pastel color tint to the dice body without tinting the black dots.
## @param player_color Godot Color of the owner player.
func apply_soft_tint(player_color: Color):
	var soft_color = Color.WHITE.lerp(player_color, 0.50)
	if not has_node("Dice"):
		return
		
	var meshes = _find_all_mesh_instances($Dice)
	for mesh_inst in meshes:
		# Force layer 1 and double-sided shadow casting so inset dot cavities do not leak light
		mesh_inst.layers = 1
		mesh_inst.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_DOUBLE_SIDED
		mesh_inst.material_override = null
		
		var surface_count = 1
		if mesh_inst.mesh:
			surface_count = mesh_inst.mesh.get_surface_count()
		
		for s_idx in range(surface_count):
			var orig_mat = mesh_inst.get_active_material(s_idx)
			var is_dots_material = false
			
			if orig_mat and orig_mat is StandardMaterial3D:
				# Detect if original albedo is dark (dots material)
				if orig_mat.albedo_color.r < 0.3 and orig_mat.albedo_color.g < 0.3 and orig_mat.albedo_color.b < 0.3:
					is_dots_material = true
			elif surface_count > 1 and s_idx > 0:
				# In multi-surface dice models where surface > 0 is dots
				is_dots_material = true
			
			if is_dots_material:
				# Keep dots surface crisp black with solid depth draw and double-sided rendering
				var dots_mat = StandardMaterial3D.new()
				dots_mat.albedo_color = Color.BLACK
				dots_mat.roughness = 0.5
				dots_mat.shading_mode = BaseMaterial3D.SHADING_MODE_PER_PIXEL
				dots_mat.depth_draw_mode = BaseMaterial3D.DEPTH_DRAW_ALWAYS
				dots_mat.cull_mode = BaseMaterial3D.CULL_DISABLED
				mesh_inst.set_surface_override_material(s_idx, dots_mat)
			else:
				# Apply soft pastel tint to dice body with solid depth draw and double-sided rendering
				var body_mat = StandardMaterial3D.new()
				if orig_mat and orig_mat is StandardMaterial3D and orig_mat.albedo_texture:
					body_mat.albedo_texture = orig_mat.albedo_texture
				body_mat.albedo_color = soft_color
				body_mat.roughness = 0.3
				body_mat.metallic_specular = 0.5
				body_mat.shading_mode = BaseMaterial3D.SHADING_MODE_PER_PIXEL
				body_mat.depth_draw_mode = BaseMaterial3D.DEPTH_DRAW_ALWAYS
				body_mat.cull_mode = BaseMaterial3D.CULL_DISABLED
				mesh_inst.set_surface_override_material(s_idx, body_mat)


## Rotates the dice 3D orientation so that a target value appears at the top.
## @param v Target face value (1 to 6).
func simulate_value(v: int) -> void:
	# Reset rotation basis before applying target face rotation
	self.global_rotate(Vector3(1, 1, 1).normalized(), 0)
	match(v):
		1:
			self.global_rotate(Vector3(1, 0, 0).normalized(), PI)
		2:
			self.global_rotate(Vector3(0, 0, 1).normalized(), 3 * PI / 2)
		3:
			self.global_rotate(Vector3(1, 0, 0).normalized(), PI / 2)
		4:
			self.global_rotate(Vector3(1, 0, 0).normalized(), 3 * PI / 2)
		5:
			self.global_rotate(Vector3(0, 0, 1).normalized(), PI / 2)
		6:
			self.global_rotate(Vector3(1, 0, 0).normalized(), 0)


## Checks if any active piece is standing in the vertical column underneath the given position.
## @param pos Candidate 3D position to check.
## @param threshold_distance Minimum allowed 2D clearance distance.
## @return True if a piece is detected within the clearance radius.
func is_piece_under_position(pos: Vector3, threshold_distance: float = 3.5) -> bool:
	# Verify player and board references exist
	if not self.player() or not self.player().board():
		return false
	# Iterate through all players and their active pieces
	for p in self.player().board().players():
		for piece in p.pieces():
			if piece.visible:
				var piece_pos = piece.global_transform.origin
				# Check 2D distance on XZ plane ignoring height difference
				var dist_2d = Vector2(pos.x - piece_pos.x, pos.z - piece_pos.z).length()
				if dist_2d < threshold_distance:
					return true
	return false


## Calculates a dynamic random spawn position for the dice along the player's board area.
## @return Vector3 initial spawn position.
func get_random_launch_origin() -> Vector3:
	var h = randf_range(5.0, 7.0)
	var p_id = self.player().id if self.player() else 0
	var max_p = self.player().board().max_players if (self.player() and self.player().board()) else 4
	
	if max_p == 6:
		match p_id:
			0: return Vector3(randf_range(-10.0, 10.0), h, randf_range(-32.0, -20.0))
			1: return Vector3(randf_range(-32.0, -20.0), h, randf_range(-20.0, -5.0))
			2: return Vector3(randf_range(-32.0, -20.0), h, randf_range(5.0, 20.0))
			3: return Vector3(randf_range(-10.0, 10.0), h, randf_range(20.0, 32.0))
			4: return Vector3(randf_range(20.0, 32.0), h, randf_range(5.0, 20.0))
			5: return Vector3(randf_range(20.0, 32.0), h, randf_range(-20.0, -5.0))
			_: return Vector3(randf_range(-20.0, 20.0), h, randf_range(-20.0, 20.0))
	elif max_p == 8:
		match p_id:
			0: return Vector3(randf_range(-10.0, 10.0), h, randf_range(26.0, 38.0))
			1: return Vector3(randf_range(-30.0, -18.0), h, randf_range(18.0, 30.0))
			2: return Vector3(randf_range(-38.0, -26.0), h, randf_range(-10.0, 10.0))
			3: return Vector3(randf_range(-30.0, -18.0), h, randf_range(-30.0, -18.0))
			4: return Vector3(randf_range(-10.0, 10.0), h, randf_range(-38.0, -26.0))
			5: return Vector3(randf_range(18.0, 30.0), h, randf_range(-30.0, -18.0))
			6: return Vector3(randf_range(26.0, 38.0), h, randf_range(-10.0, 10.0))
			7: return Vector3(randf_range(18.0, 30.0), h, randf_range(18.0, 30.0))
			_: return Vector3(randf_range(-25.0, 25.0), h, randf_range(-25.0, 25.0))
	else:
		match p_id:
			0: return Vector3(randf_range(-30.0, -12.0), h, randf_range(-30.0, -12.0))
			1: return Vector3(randf_range(-30.0, -12.0), h, randf_range(12.0, 30.0))
			2: return Vector3(randf_range(12.0, 30.0), h, randf_range(12.0, 30.0))
			3: return Vector3(randf_range(12.0, 30.0), h, randf_range(-30.0, -12.0))
			_: return Vector3(randf_range(-25.0, 25.0), h, randf_range(-25.0, 25.0))


## Scans the 2D board floor to find a landing spot closest to player's exit square with large clearance to pieces.
## @return Vector2 2D horizontal coordinates (X, Z) on the board floor.
func find_empty_board_spot() -> Vector2:
	# 1. Determine player's starting exit square 2D position
	var start_square_id = 5
	if self.player():
		if self.player().route() and self.player().route().square_at(1):
			start_square_id = self.player().route().square_at(1).id
		else:
			match self.player().id:
				0: start_square_id = 5
				1: start_square_id = 22
				2: start_square_id = 39
				3: start_square_id = 56
				4: start_square_id = 73
				5: start_square_id = 90
				6: start_square_id = 107
				7: start_square_id = 124
	
	var board_obj = self.player().board() if (self.player() and self.player().board()) else null
	var exit_3d = board_obj.get_position3d(start_square_id, 0) if board_obj else Globals.position4(start_square_id, 0)
	var exit_2d = Vector2(exit_3d.x, exit_3d.z)

	# 2. Collect 2D floor coordinates of all active standing pieces
	var piece_positions: Array[Vector2] = []
	if board_obj:
		for p in board_obj.players():
			for piece in p.pieces():
				if piece.visible:
					var pos3d = piece.global_transform.origin
					piece_positions.append(Vector2(pos3d.x, pos3d.z))
					if piece.square():
						var sq_pos = piece.get_3d_position(piece.square().id, piece.square_position)
						piece_positions.append(Vector2(sq_pos.x, sq_pos.z))

	# 3. Fine-grid search across board floor (X: -26 to 26, Z: -26 to 26)
	var step = 2.5
	var best_spot = exit_2d
	var best_score = -999999.0
	var safe_candidates: Array[Dictionary] = []

	for target_x in range(-26, 27, int(step)):
		for target_z in range(-26, 27, int(step)):
			var spot = Vector2(float(target_x), float(target_z))

			# Calculate minimum distance to any standing piece
			var min_dist_to_piece = 999.0
			for p_pos in piece_positions:
				var d = spot.distance_to(p_pos)
				if d < min_dist_to_piece:
					min_dist_to_piece = d

			var dist_to_exit = spot.distance_to(exit_2d)

			# Group candidate spots with large clearance (>= 8.0 units) from pieces
			if min_dist_to_piece >= 8.0:
				safe_candidates.append({
					"spot": spot,
					"dist_to_exit": dist_to_exit,
					"clearance": min_dist_to_piece
				})

			# Scoring function balancing piece clearance and proximity to player exit square
			var score = (min_dist_to_piece * 3.0) - dist_to_exit
			if score > best_score:
				best_score = score
				best_spot = spot

	# Pick safe candidate spot with large clearance that is CLOSEST to player exit square
	if safe_candidates.size() > 0:
		safe_candidates.sort_custom(func(a, b): return a["dist_to_exit"] < b["dist_to_exit"])
		return safe_candidates[0]["spot"]

	return best_spot


## Relocates the dice launch position to a completely new corner/side of the board when a tilt occurs.
func relaunch_from_new_position():
	var alternate_corners = [
		Vector3(-25, randf_range(9.0, 11.5), -25),
		Vector3(-25, randf_range(9.0, 11.5), 25),
		Vector3(25, randf_range(9.0, 11.5), 25),
		Vector3(25, randf_range(9.0, 11.5), -25),
		Vector3(0, randf_range(9.0, 11.5), -28),
		Vector3(0, randf_range(9.0, 11.5), 28),
		Vector3(-28, randf_range(9.0, 11.5), 0),
		Vector3(28, randf_range(9.0, 11.5), 0)
	]
	alternate_corners.shuffle()
	
	var new_pos = alternate_corners[0]
	for candidate in alternate_corners:
		if candidate.distance_to(self.global_transform.origin) > 15.0:
			new_pos = candidate
			break
			
	self.global_transform.origin = new_pos
	self.launch()


## Launches the dice towards the center of the board with random physical forces and torque.
func launch():
	# Configure physical parameters and timers for new throw
	self.mass = 1.2
	self.stopped_frames = 0
	$RelaunchTimer.start(8)
	self.player().can_throw_dice = false
	self.value = null
	self.has_touch = false
	self.collision_count = 0
	self.freeze = false
	
	self.set_physics_process(true)
	
	# Check if a fake dice queue is configured for debug/testing
	if len(Globals.game_data["fake_dice"]) > 0:
		var fake = int(Globals.game_data["fake_dice"][0])
		self.simulate_value(fake)
		self.set_my_position(5)
		var dir = (Vector3(0, 0, 0) - Vector3(self.global_transform.origin.x, 0, self.global_transform.origin.z)).normalized()
		self.set_linear_velocity(dir * 12.0 + Vector3(0, 2.0, 0))
		self.set_angular_velocity(Vector3(randf_range(-20.0, 20.0), randf_range(-3.0, 3.0), randf_range(-20.0, 20.0)))
	else:
		randomize()
		# 1. Find a 2D spot on the horizontal plane with maximum clearance to all pieces
		var empty_spot2d = find_empty_board_spot()
		
		# 2. Position the dice directly above the empty spot at an increased height Y = 8.5 to 11.0
		self.global_transform.origin = Vector3(empty_spot2d.x, randf_range(8.5, 11.0), empty_spot2d.y)
		self.simulate_value(int(randf_range(1, 6.99)))
		
		# 3. Apply tiny horizontal drift + downward drop velocity so it drops straight down in that empty spot
		var tiny_drift_x = randf_range(-0.8, 0.8)
		var tiny_drift_z = randf_range(-0.8, 0.8)
		self.set_linear_velocity(Vector3(tiny_drift_x, -1.8, tiny_drift_z))
		
		# 4. Apply 3D tumbling rotation so it rolls locally on landing
		self.set_angular_velocity(Vector3(randf_range(-16.0, 16.0), randf_range(-4.0, 4.0), randf_range(-16.0, 16.0)))


## Callback triggered when the dice collides with another physics body.
## @param _body Body node collided with.
func _on_body_entered(_body):
	# 1. Only play collision sound effect when the dice is actively rolling (value is null during throw)
	if self.value != null:
		return

	# 2. Play collision audio effect with randomized pitch
	$Touched.pitch_scale = randf_range(0.9, 1.1)
	$Touched.volume_db = 0.0
	$Touched.play()


## Validates whether a face RayCast is pointing straight DOWN towards the ground.
## @param rc RayCast3D node instance.
## @return True if the face is flat on the ground (dot product > 0.95).
func is_ray_flat(rc: RayCast3D) -> bool:
	if not rc.is_colliding():
		return false
	# Transform RayCast local direction to global space
	var global_dir = (rc.global_transform.basis * rc.target_position).normalized()
	# Check alignment with vertical DOWN vector
	return global_dir.dot(Vector3.DOWN) > 0.95


## Physics frame loop handling bounds safety, face detection, and roll resolution.
## @param _delta Frame delta time.
func _physics_process(_delta):
	if self.value == 0:
		return

	# Out of bounds safety recovery if dice falls below floor
	if self.global_transform.origin.y < -5.0:
		self.global_transform.origin.y = 8.0
		self.set_linear_velocity(Vector3.ZERO)
		self.launch()
		return

	# Determine current flat face value from RayCasts
	self.value = null
	if is_ray_flat($RC1):
		self.value = 6
		self.has_touch = true
	elif is_ray_flat($RC2):
		self.value = 5
		self.has_touch = true
	elif is_ray_flat($RC3):
		self.value = 4
		self.has_touch = true
	elif is_ray_flat($RC4):
		self.value = 3
		self.has_touch = true
	elif is_ray_flat($RC5):
		self.value = 2
		self.has_touch = true
	elif is_ray_flat($RC6):
		self.value = 1
		self.has_touch = true
	
	# Check velocity thresholds and ground contact to determine if the roll has settled
	var is_on_ground = self.global_transform.origin.y <= 2.2
	var is_tumbling_stopped = abs(self.angular_velocity.x) < 0.2 and abs(self.angular_velocity.z) < 0.2
	var is_linear_stopped = Globals.vector_is_almost_zero(self.linear_velocity, 0.2)
	
	if is_on_ground and is_tumbling_stopped and is_linear_stopped:
		self.stopped_frames += 1
	else:
		self.stopped_frames = 0
		
	# Require 20 continuous stopped frames on ground (~0.33s) before settling
	if self.stopped_frames >= 20:
		self.stopped_frames = 0
		if self.value != null:
			# Roll successfully finished with a flat face
			var s = "Dice " + str(self.player().id) + " gets a " + str(self.value)
			print(s)
			$RelaunchTimer.stop()
			
			self.set_linear_velocity(Vector3.ZERO)
			self.set_angular_velocity(Vector3.ZERO)
			self.freeze = true
			self.set_physics_process(false)
			
			# Handle fake dice override if active
			if len(Globals.game_data["fake_dice"]) > 0:
				self.value = int(Globals.game_data["fake_dice"].pop_front())
				print("Fake dice: {0}".format([self.value]))
				$FloatingText.show_text(tr("Fake dice: {0}").format([self.value]), self.player().color)
			
			self.player().dice_throws.append(self.value)
			self.historical.append(self.value)
			emit_signal("dice_got_value")
		else:
			# Stopped cocked or tilted on an edge; relocate launch point completely and re-roll
			print("Dice stopped oblique/tilted - Changing launch point completely and relaunching...")
			$FloatingText.show_text(tr("Tilted dice - Rerolling from new position"), self.player().color)
			self.relaunch_from_new_position()


## Handles dice click input event to trigger throw and evaluate game rules.
func on_clicked():
	self.launch()
	await self.dice_got_value
	
	# Evaluate three sixes rule penalty
	var lpm = self.player().last_piece_moved
	if self.player().dice_throws_has_three_sixes() and lpm != null:
		if self.player().route().is_ramp(lpm.route_position) == true:
			self.player().game().change_current_player()	
			$FloatingText.show_text(tr("Tree sixes: You're lucky you are in the final ramp"), self.player().color)
			await $FloatingText.text_disappear
			return
		elif lpm.can_move_stm() == false:
			self.player().game().change_current_player()			
			$FloatingText.show_text(tr("Tree sixes: You're lucky you can't move"), self.player().color)
			await $FloatingText.text_disappear
			return
		elif self.player().route().is_ramp(self.player().last_piece_moved.route_position) == false:
			$ThreeSix.play()
			self.player().last_piece_moved.move_to_route_position(0)
			await self.player().last_piece_moved.piece_moved
			$FloatingText.show_text(tr("Tree sixes: too fast too young"), self.player().color)
			await $FloatingText.text_disappear
			self.player().game().change_current_player()
			return
		
	# Handle piece selection or next player turn
	if self.player().can_some_piece_move_stm():
		# Notify player when rolling a 5 requires leaving home
		if self.value == 5 and self.player().can_some_piece_move_to_first_square():
			$FloatingText.show_text(tr("A 5! You must leave home"), self.player().color)
			
		self.player().can_move_pieces = true
		if self.player().ia == true:
			var p = self.player().ia_selects_piece_to_move()
			p.on_clicked()
		else:
			var pieces_can_move_stm = self.player().pieces_can_move_stm()
			if pieces_can_move_stm.size() == 1:
				pieces_can_move_stm[0].on_clicked()
	else:
		if self.player().can_throw_dice_again():
			self.player().can_throw_dice = true
			if self.player().ia == true or Globals.settings["automatic"] == true:
				self.player().dice().on_clicked()
		else:
			self.player().game().change_current_player()


## Generates a statistical summary report of past throws for this dice.
## @return Formatted string containing throw percentages and repetitions.
func historical_report():
	var s = ""
	if len(self.historical) > 0:
		s += "Dice %s has been thrown %s times:\n" % [self.player().id, self.historical.size()]
		s += "  - 1: %d (%.2f%%)\n" % [self.historical.count(1), float(self.historical.count(1)) / len(self.historical) * 100]
		s += "  - 2: %d (%.2f%%)\n" % [self.historical.count(2), float(self.historical.count(2)) / len(self.historical) * 100]
		s += "  - 3: %d (%.2f%%)\n" % [self.historical.count(3), float(self.historical.count(3)) / len(self.historical) * 100]
		s += "  - 4: %d (%.2f%%)\n" % [self.historical.count(4), float(self.historical.count(4)) / len(self.historical) * 100]
		s += "  - 5: %d (%.2f%%)\n" % [self.historical.count(5), float(self.historical.count(5)) / len(self.historical) * 100]
		s += "  - 6: %d (%.2f%%)\n" % [self.historical.count(6), float(self.historical.count(6)) / len(self.historical) * 100]
		if len(self.historical) > 1:
			var repetitions = 0
			for i in range(1, len(self.historical)):
				if self.historical[i] == self.historical[i - 1]:
					repetitions += 1
			s += "  - Repetitions: %d" % repetitions
	return s


## Callback for relaunch timer timeout when dice gets stuck.
func _on_RelaunchTimer_timeout():
	if $RelaunchTimer.is_stopped():
		return
	else:
		self.global_rotate(Vector3.UP, 0)
		self.set_linear_velocity(Vector3.ZERO)
		self.set_angular_velocity(Vector3.ZERO)
		$FloatingText.show_text(tr("Recovering dice"), self.player().color)
		self.player().can_throw_dice = true
		self.launch()


## Helper method for TweenWaiting interpolation.
## @param rad Angle in radians.
func TweenWaiting_method(rad):
	self.global_transform.origin.y = 2.5 + sin(rad) / 2


## Starts the floating hover animation for dice selection.
func TweenWaiting_start():  
	self.set_physics_process(false)	
	self.freeze = true
	self.tween_waiting = create_tween()
	self.tween_waiting.set_loops()
	self.tween_waiting.tween_method(TweenWaiting_method, 0, 2 * PI, 2)


## Stops the floating hover animation.
func TweenWaiting_stop():
	self.tween_waiting.kill()
	self.freeze = false
	self.set_physics_process(true)
