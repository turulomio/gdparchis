class_name Dice
extends RigidBody3D

signal dice_got_value

var vel : Vector3 = Vector3(0, -30, 0)
var value = 0 # 0: uninitialized, null: rolling in progress, 1-6: face result determined
var has_touch = false
var collision_count: int = 0
var historical = [] # List storing all past rolls for statistics reporting
var tween_waiting


## Returns the parent Player node associated with this dice.
## @return Player node instance.
func player():
	return self.get_parent_node_3d()


## Sets the initial spawn coordinates of the dice according to the player ID.
## @param h Height (Y coordinate) where the dice will be spawned.
func set_my_position(h):
	# Match player ID to set its corner spawn position
	match(self.player().id):
		0:
			self.global_transform.origin = Vector3(-20, h, -25)
		1:
			self.global_transform.origin = Vector3(-25, h, 20)
		2:
			self.global_transform.origin = Vector3(20, h, 25)
		3:
			self.global_transform.origin = Vector3(25, h, -20)


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


## Launches the dice towards the center of the board with random physical forces and torque.
func launch():
	# Configure physical parameters and timers for new throw
	self.mass = 1.2
	$RelaunchTimer.start(5)
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
		# Randomize spawn height and face orientation
		randomize()
		self.set_my_position(randf_range(4.5, 6.5))
		self.simulate_value(int(randf_range(1, 6.99)))
		
		# Ensure vertical launch line is clear of any standing pieces
		var spawn_pos = self.global_transform.origin
		var shift_dir = (Vector3(0, 0, 0) - Vector3(spawn_pos.x, 0, spawn_pos.z)).normalized()
		var attempts = 0
		while is_piece_under_position(spawn_pos, 3.5) and attempts < 8:
			attempts += 1
			spawn_pos += Vector3(shift_dir.x * 2.0, 0, shift_dir.z * 2.0)
		
		# Apply calculated spawn position and throw velocities
		self.global_transform.origin = spawn_pos
		var dir_to_center = (Vector3(0, 0, 0) - Vector3(spawn_pos.x, 0, spawn_pos.z)).normalized()
		var toss_speed = randf_range(9.0, 14.0)
		var upward_force = randf_range(1.5, 3.0)
		
		self.set_linear_velocity(dir_to_center * toss_speed + Vector3(0, upward_force, 0))
		# Apply tumbling angular rotation on X and Z axes
		self.set_angular_velocity(Vector3(randf_range(-25.0, 25.0), randf_range(-4.0, 4.0), randf_range(-25.0, 25.0)))


## Callback triggered when the dice collides with another physics body.
## @param _body Body node collided with.
func _on_body_entered(_body):
	# Play collision audio effect with randomized pitch
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
	
	# Check velocity thresholds to determine if the roll has stopped
	var is_tumbling_stopped = abs(self.angular_velocity.x) < 0.2 and abs(self.angular_velocity.z) < 0.2
	var is_linear_stopped = Globals.vector_is_almost_zero(self.linear_velocity, 0.2)
	
	if is_tumbling_stopped and is_linear_stopped:
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

				# Register end of fake game if needed
				var fields = {
					"game_uuid": Globals.game_data.game_uuid,
					"faked": true,
				}
				Globals.request_put($RequestGameEnd, Globals.APIROOT + "/games/", fields)
				$FloatingText.show_text(tr("Fake dice: {0}").format([self.value]), self.player().color)
			
			self.player().dice_throws.append(self.value)
			self.historical.append(self.value)
			emit_signal("dice_got_value")
		else:
			# Stopped cocked or tilted on an edge; trigger automatic re-roll
			print("Dice stopped oblique/tilted - Relaunching...")
			$FloatingText.show_text(tr("Tilted dice - Rerolling"), self.player().color)
			self.launch()


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


## HTTP request completion handler for game faked endpoint.
func _on_RequestGameFake_request_completed(result, response_code, headers, body):
	if result == 0:
		var r = JSON.parse_string(body.get_string_from_utf8())
		print("  - ", r["success"], ": ", r["detail"])
	else:
		print("  -  Couldn't connect")
