extends Node3D
class_name Game4

@onready var OrCamera = $Camera
@onready var OrBoard = $Board4
@onready var OrPopup = $Popup
var current_player
var game_start_time: float = 0.0
var is_dragging_camera: bool = false
var camera_sensitivity: float = 0.005
var orbit_yaw: float = 0.0
var orbit_pitch: float = 0.6
var orbit_radius: float = 65.0
var _last_cam_pos: Vector3 = Vector3.ZERO


## Returns the Board4 child node instance.
## @return Board4 node.
func board():
	return $Board4


## Performs a 3D raycast query from mouse position into the scene world.
## @return Physics object collider hit by raycast, or null.
func get_object_under_mouse():
	var mouse_pos = OrCamera.project_ray_origin(get_viewport().get_mouse_position())
	var ray_from = OrCamera.project_ray_origin(get_viewport().get_mouse_position())
	var ray_to = ray_from + OrCamera.project_ray_normal(get_viewport().get_mouse_position()) * 100
	var space_state = get_world_3d().direct_space_state
	var selection = space_state.intersect_ray(PhysicsRayQueryParameters3D.create(ray_from, ray_to))
	if len(selection) == 0:
		return null
	return selection.collider


## Evaluates if any active player has won and triggers the game victory completion sequence.
## @return True if a winner was confirmed and game transition initiated.
func check_game_over() -> bool:
	for player in self.board().players_than_plays():
		if player.has_won():
			Globals.add_game_history_entry(self.game_start_time, player, self.board())
			$DebugFloatingText.show_text(tr("Player {0} wins").format([player.playername]), player.color)
			await $DebugFloatingText.text_disappear
			
			print("Registering end of game:")	
			var fields = {
				"game_uuid": Globals.game_data.game_uuid,
				"human_won": not player.ia,
			}
			print(fields)
			get_tree().change_scene_to_file.call_deferred("res://scenes/Main.tscn")
			return true
	return false


## Scene entry point. Initializes board data, player turns, and auto-throws if AI.
func _ready():	
	print("LOADING GAME4")
	self.game_start_time = Time.get_unix_time_from_system()
	var d = Globals.game_data

	# Check if transition came from GameDiceStart (pieces already animated) or saved game load
	var animate = not Globals.from_dice_start
	Globals.from_dice_start = false

	# Load global game state into board and pieces and wait for piece placement to complete
	await Globals.game_load_glogals_game_data(self, true, animate)

	# Check if any active player has already won upon loading scene
	if await self.check_game_over():
		return

	# Set active starting player
	self.current_player = self.board().players()[d["current"]]
	self.current_player.can_move_pieces = false
	self.current_player.dice_throws = []
	self.current_player.can_throw_dice = true
	
	# Skip turn if starting player is non-participating or has won
	if self.current_player.plays == false or self.current_player.has_won():
		self.change_current_player()
		return

	# Update dice visibility so only current player's dice is visible
	for p in self.board().players():
		p.dice().visible = (p == self.current_player)
	
	# Automatically trigger dice throw for AI or automatic mode
	if self.current_player.ia == true or Globals.settings.get("automatic", true):
		self.current_player.dice().on_clicked()


## Frame process loop handling mouse click interactions, camera shortcuts, and fullscreen toggles.
## @param _delta Delta frame time.
func _process(_delta):
	# Handle left click interactions with Piece or Dice
	if Input.is_action_just_pressed("left_click"):
		var object = get_object_under_mouse()
		if object == null:
			return
		if object is Piece:
			if object.player() == self.current_player and object.player().can_move_pieces:
				object.on_clicked()
			else:
				$Click.play()
		if object is Dice:
			if object.player() == self.current_player and object.player().can_throw_dice:
				object.on_clicked()
			else:
				$Click.play()

	# Process preset camera view angles
	if Input.is_action_just_pressed("top_view"):
		OrCamera.look_at_from_position(Vector3(0, 50, 0), Vector3(0, 0, 0.001), Vector3.UP)
		OrCamera.global_rotate(Vector3(0, 1, 0), PI)
	if Input.is_action_just_pressed("bottom_view"):
		OrCamera.look_at_from_position(Vector3(0, -50, 0), Vector3(0, 0, -0.001), Vector3.UP)
		OrCamera.global_rotate(Vector3(0, 1, 0), PI)
	if Input.is_action_just_pressed("yellow_view"):
		OrCamera.look_at_from_position(Vector3(-18, 48, -18), Vector3(0, -11.0, 0), Vector3.UP)
	if Input.is_action_just_pressed("blue_view"):
		OrCamera.look_at_from_position(Vector3(-18, 48, 18), Vector3(0, -11.0, 0), Vector3.UP)
	if Input.is_action_just_pressed("red_view"):
		OrCamera.look_at_from_position(Vector3(18, 48, 18), Vector3(0, -11.0, 0), Vector3.UP)
	if Input.is_action_just_pressed("green_view"):
		OrCamera.look_at_from_position(Vector3(18, 48, -18), Vector3(0, -11.0, 0), Vector3.UP)
	if Input.is_action_just_pressed("yellow_view_floor"):
		OrCamera.look_at_from_position(Vector3(-30, 1, -30), Vector3(0, 1, 0), Vector3.UP)
	if Input.is_action_just_pressed("blue_view_floor"):
		OrCamera.look_at_from_position(Vector3(-30, 1, 30), Vector3(0, 1, 0), Vector3.UP)
	if Input.is_action_just_pressed("red_view_floor"):
		OrCamera.look_at_from_position(Vector3(30, 1, 30), Vector3(0, 1, 0), Vector3.UP)
	if Input.is_action_just_pressed("green_view_floor"):
		OrCamera.look_at_from_position(Vector3(30, 1, -30), Vector3(0, 1, 0), Vector3.UP)
		
	# Process camera zoom
	if Input.is_action_just_pressed("zoom_in") or Input.is_action_pressed("zoom_in"):
		zoom_camera(-1.5)
	if Input.is_action_just_pressed("zoom_out") or Input.is_action_pressed("zoom_out"):
		zoom_camera(1.5)

	# Handle toggle sound shortcut ('S' key) and display notification on board
	if Input.is_action_just_pressed("toggle_sound"):
		var is_sound_enabled = Globals.toggle_sound()
		var msg = tr("Sound ON") if is_sound_enabled else tr("Sound OFF")
		var text_color = Color.GREEN if is_sound_enabled else Color.RED
		$DebugFloatingText.show_text(msg, text_color)

	# Handle exit key shortcut back to main menu
	if Input.is_action_just_pressed("exit"):
		for player in self.board().players():
			if player.plays:
				player.dice().historical_report()
		get_tree().change_scene_to_file.call_deferred("res://scenes/Main.tscn")


## Handles unhandled mouse wheel events for zooming and mouse drag for 3D board orbit rotation.
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


## Syncs spherical coordinate angles with current camera position if camera moved externally.
func update_orbit_from_camera_if_needed():
	if OrCamera.global_transform.origin != _last_cam_pos:
		var target = Vector3(0, 0, 0)
		var offset = OrCamera.global_transform.origin - target
		orbit_radius = offset.length()
		if orbit_radius > 0.001:
			var ratio = clamp(offset.y / orbit_radius, -1.0, 1.0)
			orbit_pitch = clamp(asin(ratio), 0.08, 1.45)
			orbit_yaw = atan2(offset.x, offset.z)
		_last_cam_pos = OrCamera.global_transform.origin


## Orbits 3D camera around board center (0, 0, 0) using spherical coordinates to eliminate gimbal lock flickering.
## @param relative Mouse movement vector.
func orbit_camera(relative: Vector2):
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
## @param amount Zoom distance offset (negative for zoom in, positive for zoom out).
func zoom_camera(amount: float):
	var forward = -OrCamera.global_transform.basis.z.normalized()
	var new_pos = OrCamera.global_transform.origin + forward * (-amount)
	if new_pos.y >= 8.0 and new_pos.y <= 120.0:
		OrCamera.global_transform.origin = new_pos
		
	# Handle right-click debug popup info
	if Input.is_action_just_pressed("right_click"):
		var object = get_object_under_mouse()
		if object == null:
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


## Rotates turn to next participating player, saves game state, and initiates turn action.
func change_current_player():
	# Check if an active player has won before changing turn
	if await self.check_game_over():
		return

	# Cycle player turn dynamically using modulo arithmetic
	var all_players = self.board().players()
	if self.current_player == null:
		self.current_player = all_players[0]
	else:
		var curr_idx = all_players.find(self.current_player)
		self.current_player = all_players[(curr_idx + 1) % all_players.size()]
		
	print("Current player now is ", self.current_player.playername)
		
	# Skip inactive non-participating players or players who have already won
	if self.current_player.plays == false or self.current_player.has_won():
		self.change_current_player()
		return
		
	# Reset state variables for new turn
	self.current_player.last_piece_moved = null
	self.current_player.can_move_pieces = false
	self.current_player.dice_throws = []
	self.current_player.extra_moves = []
	self.current_player.can_throw_dice = true
	
	# Update dice visibility so only current player's dice is visible
	for p in self.board().players():
		p.dice().visible = (p == self.current_player)
	
	# Realign and drop all active pieces on the board to correct any displacement
	for p in self.board().players():
		for piece in p.pieces():
			if piece.visible:
				piece.correct_position_and_drop(0.12)
	
	# Autosave current game progress
	Globals.save_game(self)
	
	# Auto-trigger dice throw for AI or automatic mode
	if self.current_player.ia == true:
		self.current_player.dice().on_clicked()
	else:
		if Globals.settings.get("automatic", true) == true:
			self.current_player.dice().on_clicked()
