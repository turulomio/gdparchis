extends Node3D
class_name GameBase

@onready var OrCamera = $Camera if has_node("Camera") else null
@onready var OrPopup = $Popup if has_node("Popup") else null

var current_player = null
var game_start_time: float = 0.0
var is_dragging_camera: bool = false
var camera_sensitivity: float = 0.005
var orbit_yaw: float = 0.0
var orbit_pitch: float = 0.6
var orbit_radius: float = 65.0
var _last_cam_pos: Vector3 = Vector3.ZERO
var _touch_start_pos: Vector2 = Vector2.ZERO
var _touch_press_time: float = 0.0
var _is_touch_dragging: bool = false


## System notification handler for Android back button (Escape key emulation).
## @param what Notification type identifier.
func _notification(what: int):
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		for player in self.board().players():
			if player.plays:
				player.dice().historical_report()
		get_tree().change_scene_to_file.call_deferred("res://scenes/Main.tscn")


## Returns the BoardBase child node instance.
## Virtual method to be overridden by child scenes if board node name differs.
## @return BoardBase node instance.
func board() -> BoardBase:
	for child in get_children():
		if child is BoardBase:
			return child
	return null


## Performs a 3D raycast query from a 2D screen position into the scene world.
## @param screen_pos 2D position on screen.
## @return Physics object collider hit by raycast, or null.
func get_object_at_position(screen_pos: Vector2):
	if not OrCamera:
		return null
	var ray_from = OrCamera.project_ray_origin(screen_pos)
	var ray_to = ray_from + OrCamera.project_ray_normal(screen_pos) * 100
	var space_state = get_world_3d().direct_space_state
	var selection = space_state.intersect_ray(PhysicsRayQueryParameters3D.create(ray_from, ray_to))
	if len(selection) == 0:
		return null
	return selection.collider


## Performs a 3D raycast query from mouse position into the scene world.
## @return Physics object collider hit by raycast, or null.
func get_object_under_mouse():
	return get_object_at_position(get_viewport().get_mouse_position())


## Handles click or touch interaction with 3D object (Piece or Dice).
## @param object Physics object hit by 3D raycast query.
func handle_object_click(object):
	if object == null:
		return
		
	if object is Piece:
		if object.player() == self.current_player and object.player().can_move_pieces:
			object.on_clicked()
		else:
			var click_sound = get_node_or_null("Click")
			if click_sound:
				click_sound.play()
			
	if object is Dice:
		if object.player() == self.current_player and object.player().can_throw_dice:
			object.on_clicked()
		else:
			var click_sound = get_node_or_null("Click")
			if click_sound:
				click_sound.play()


## Handles right-click or long-press touch interaction displaying piece/dice detail popup.
## @param object Physics object hit by 3D raycast query.
func handle_object_right_click(object):
	if object == null or not OrPopup:
		return
		
	if object is Piece:
		var s = "Piece " + str(object) + " " + object.player().playername + "\n"
		if object.player() == self.current_player and object.player().can_move_pieces:
			s += "  + Can move: " + str(object.can_move_stm())
			s += "  + Can eat before: " + str(object.can_eat_before_stm())
			s += "  + Can eat after: " + str(object.can_eat_at_route_position(object.route_position + object.squares_to_move(), false))
			s += "  + Threats before: " + str(object.threats_at(object.square()))
			s += "  + Threats after: " + str(object.threats_at(object.route().square_at(object.route_position + object.squares_to_move())))
		OrPopup.set_text(s)
		
	if object is Dice and OS.is_debug_build():
		OrPopup.set_text(object.historical_report())


## Evaluates if any active player has won and triggers the game victory completion sequence.
## @return True if a winner was confirmed and game transition initiated.
func check_game_over() -> bool:
	if not self.board():
		return false
		
	for player in self.board().players_than_plays():
		if player.has_won():
			Globals.add_game_history_entry(self.game_start_time, player, self.board())
			var debug_lbl = get_node_or_null("DebugFloatingText")
			if debug_lbl:
				debug_lbl.show_text(tr("Player {0} wins").format([player.playername]), player.color)
				await debug_lbl.text_disappear
			
			print("Registering end of game:")	
			var fields = {
				"game_uuid": Globals.game_data.game_uuid,
				"human_won": not player.ia,
			}
			print(fields)
			get_tree().change_scene_to_file.call_deferred("res://scenes/Main.tscn")
			return true
	return false


## Handles unhandled mouse wheel events, mouse drags, and touch screen inputs for camera orbit.
## @param event Input event object.
func _unhandled_input(event: InputEvent):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT:
			is_dragging_camera = event.is_pressed()
		elif event.is_pressed():
			if event.button_index == MOUSE_BUTTON_WHEEL_UP:
				zoom_camera(-2.5)
			elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				zoom_camera(2.5)
				
	elif event is InputEventMouseMotion and is_dragging_camera:
		orbit_camera(event.relative)
		
	elif event is InputEventScreenTouch:
		if event.pressed:
			_touch_start_pos = event.position
			_touch_press_time = Time.get_ticks_msec()
			_is_touch_dragging = false
		else:
			if not _is_touch_dragging:
				var press_duration = (Time.get_ticks_msec() - _touch_press_time) / 1000.0
				var object = get_object_at_position(event.position)
				if press_duration >= 0.4:
					if object != null:
						handle_object_right_click(object)
					else:
						var is_sound_enabled = Globals.toggle_sound()
						var msg = tr("Sound ON") if is_sound_enabled else tr("Sound OFF")
						var text_color = Color.GREEN if is_sound_enabled else Color.RED
						var debug_text = get_node_or_null("DebugFloatingText")
						if debug_text:
							debug_text.show_text(msg, text_color)
					get_viewport().set_input_as_handled()
				else:
					if object != null:
						handle_object_click(object)
						get_viewport().set_input_as_handled()
					
	elif event is InputEventScreenDrag:
		if OS.has_feature("mobile") or OS.get_name() in ["Android", "iOS"]:
			if (event.position - _touch_start_pos).length() > 15.0:
				_is_touch_dragging = true
				orbit_camera(event.relative)


## Syncs spherical coordinate angles with current camera position if camera moved externally.
func update_orbit_from_camera_if_needed():
	if not OrCamera:
		return
	if OrCamera.global_transform.origin != _last_cam_pos:
		var target = Vector3(0, 0, 0)
		var offset = OrCamera.global_transform.origin - target
		orbit_radius = offset.length()
		if orbit_radius > 0.001:
			var ratio = clamp(offset.y / orbit_radius, -1.0, 1.0)
			orbit_pitch = clamp(asin(ratio), 0.08, 1.45)
			orbit_yaw = atan2(offset.x, offset.z)
		_last_cam_pos = OrCamera.global_transform.origin


## Orbits 3D camera around board center (0, 0, 0) using spherical coordinates.
## @param relative Mouse movement vector.
func orbit_camera(relative: Vector2):
	if not OrCamera:
		return
	update_orbit_from_camera_if_needed()
	orbit_yaw -= relative.x * camera_sensitivity
	orbit_pitch = clamp(orbit_pitch - relative.y * camera_sensitivity, 0.08, 1.45)
	
	var target = Vector3(0, 0, 0)
	var x = orbit_radius * cos(orbit_pitch) * sin(orbit_yaw)
	var y = orbit_radius * sin(orbit_pitch)
	var z = orbit_radius * cos(orbit_pitch) * cos(orbit_yaw)
	
	var new_pos = target + Vector3(x, y, z)
	OrCamera.global_transform.origin = new_pos
	OrCamera.look_at(target, Vector3.UP)
	_last_cam_pos = new_pos


## Adjusts 3D camera zoom level along its viewing vector.
## @param amount Zoom distance offset.
func zoom_camera(amount: float):
	if not OrCamera:
		return
	var forward = -OrCamera.global_transform.basis.z.normalized()
	var new_pos = OrCamera.global_transform.origin + forward * (-amount)
	if new_pos.y >= 8.0 and new_pos.y <= 120.0:
		OrCamera.global_transform.origin = new_pos


## Rotates turn to next participating player, saves game state, and initiates turn action.
func change_current_player():
	if await self.check_game_over():
		return

	var all_players = self.board().players()
	if self.current_player == null:
		self.current_player = all_players[0]
	else:
		var curr_idx = all_players.find(self.current_player)
		self.current_player = all_players[(curr_idx + 1) % all_players.size()]
		
	print("Current player now is ", self.current_player.playername)
		
	if self.current_player.plays == false or self.current_player.has_won():
		self.change_current_player()
		return
		
	self.current_player.last_piece_moved = null
	self.current_player.can_move_pieces = false
	self.current_player.dice_throws = []
	self.current_player.extra_moves = []
	self.current_player.can_throw_dice = true
	
	for p in self.board().players():
		p.dice().visible = (p == self.current_player)
	
	for p in self.board().players():
		for piece in p.pieces():
			if piece.visible:
				piece.correct_position_and_drop(0.12)
	
	Globals.save_game(self)
	
	if self.current_player.ia == true:
		self.current_player.dice().on_clicked()
	else:
		if Globals.settings.get("automatic", true) == true:
			self.current_player.dice().on_clicked()
